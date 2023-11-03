//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation
import PrettyTree
import DequeModule

extension Syntax {
    /// The 'Token Tree'.
    enum TT {
        case token(Syntax.Token)
        case open(ArrayRef<TT>)
        case closed(ArrayRef<TT>)
        case fragment(ArrayRef<TT>)
    }
}

extension Syntax.TT {
    var active: ArrayRef<Self>? {
        switch self {
        case .token: return nil
        case .open(let arrayRef): return arrayRef.last?.active ?? arrayRef
        case .closed(let arrayRef): return arrayRef.last?.active
        case .fragment(let arrayRef): return arrayRef.last?.active
        }
    }
    var hasActiveSite: Bool { self.active.isSome }
    mutating func closeActiveSite() -> Bool {
        switch self {
        case .token:
            return false
        case .open(let arrayRef):
            if var last = arrayRef.elements.popLast() {
                if last.closeActiveSite() {
                    arrayRef.append(last)
                    return true
                }
                arrayRef.append(last)
            }
            self = .closed(arrayRef)
            return true
        case .closed(let arrayRef):
            if var last = arrayRef.elements.popLast() {
                if last.closeActiveSite() {
                    arrayRef.append(last)
                    return true
                }
                arrayRef.append(last)
            }
            return false
        case .fragment(let arrayRef):
            if var last = arrayRef.elements.popLast() {
                if last.closeActiveSite() {
                    arrayRef.append(last)
                    return true
                }
                arrayRef.append(last)
            }
            return false
        }
    }
    mutating func topLevelPush(tree: Syntax.TT) {
        switch self {
        case .token(let token):
            self = .fragment(.init(from: [.token(token), tree]))
        case .open:
            self = .fragment(.init(from: [self, tree]))
        case .closed:
            self = .fragment(.init(from: [self, tree]))
        case .fragment(let arrayRef):
            arrayRef.append(tree)
            self = .fragment(arrayRef)
        }
    }
    static func build(tokens: [Syntax.Token]) {
        var leading: Syntax.TT = Syntax.TT.fragment(.init())
        var trailing = tokens
        loop: while case .some(let token) = trailing.safePopFirst() {
            switch token {
            case .char:
                if let active = leading.active {
                    active.append(.token(token))
                } else {
                    leading.topLevelPush(tree: .token(token))
                }
            case .string:
                if let active = leading.active {
                    active.append(.token(token))
                } else {
                    leading.topLevelPush(tree: .token(token))
                }
            case .ident:
                if let active = leading.active {
                    active.append(.token(token))
                } else {
                    leading.topLevelPush(tree: .token(token))
                }
            case .open:
                if let active = leading.active {
                    active.append(.open(.init()))
                } else {
                    leading.topLevelPush(tree: .open(.init()))
                }
            case .close:
                if !leading.closeActiveSite() {
                    leading.topLevelPush(tree: .token(.close))
                }
            }
        }
        leading.prettyTree.print()
    }
}

extension Syntax.TT: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .token(let token):
            switch token {
            case .char(let char):
                return PrettyTree("TT.token.char('\(char)')")
            case .string(let string):
                return PrettyTree("TT.token.string(\(string.debugDescription))")
            case .ident(let string):
                return PrettyTree("TT.token.ident(\(string.debugDescription))")
            case .open:
                return PrettyTree("TT.token.open")
            case .close:
                return PrettyTree("TT.token.close")
            }
        case .open(let arrayRef):
            return PrettyTree(name: ".open", children: arrayRef.elements.map({$0.prettyTree}))
        case .closed(let arrayRef):
            return PrettyTree(name: ".closed", children: arrayRef.elements.map({$0.prettyTree}))
        case .fragment(let arrayRef):
            return PrettyTree(name: ".fragment", children: arrayRef.elements.map({$0.prettyTree}))
        }
    }
}
