//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation
import PrettyTree

extension Parser {
    enum BlockTree {
        case token(Parser.TokenValue)
        case open(Open)
        case closed(Closed)
        case fragment(ArrayRef<BlockTree>)
        struct Open {
            let open: Parser.CharToken
            let body: ArrayRef<BlockTree>
        }
        struct Closed {
            let open: Parser.CharToken
            let body: ArrayRef<BlockTree>
            let close: Parser.CharToken
        }
    }
}

extension Parser.BlockTree {
    var active: Parser.BlockTree.Open? {
        switch self {
        case .token: return nil
        case .open(let open): return open.body.last?.active ?? open
        case .closed(let closed): return closed.body.last?.active
        case .fragment(let arrayRef): return arrayRef.last?.active
        }
    }
    var hasActiveSite: Bool { self.active.isSome }
    mutating func closeActiveSite(end: Parser.CharToken) -> Bool {
        switch self {
        case .token:
            return false
        case .open(let open):
            if var last = open.body.elements.popLast() {
                if last.closeActiveSite(end: end) {
                    open.body.append(last)
                    return true
                }
                open.body.append(last)
            }
            self = .closed(.init(open: open.open, body: open.body, close: end))
            return true
        case .closed(let closed):
            if var last = closed.body.elements.popLast() {
                if last.closeActiveSite(end: end) {
                    closed.body.append(last)
                    return true
                }
                closed.body.append(last)
            }
            return false
        case .fragment(let arrayRef):
            if var last = arrayRef.elements.popLast() {
                if last.closeActiveSite(end: end) {
                    arrayRef.append(last)
                    return true
                }
                arrayRef.append(last)
            }
            return false
        }
    }
    mutating func topLevelPush(tree: Parser.BlockTree) {
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
    static func build(tokens: [Parser.TokenValue]) -> Parser.BlockTree {
        var leading: Parser.BlockTree = Parser.BlockTree.fragment(.init())
        var trailing = tokens
        loop: while case .some(let token) = trailing.safePopFirst() {
            switch token {
            case .char:
                if let active = leading.active {
                    active.body.append(.token(token))
                } else {
                    leading.topLevelPush(tree: .token(token))
                }
            case .string:
                if let active = leading.active {
                    active.body.append(.token(token))
                } else {
                    leading.topLevelPush(tree: .token(token))
                }
            case .ident:
                if let active = leading.active {
                    active.body.append(.token(token))
                } else {
                    leading.topLevelPush(tree: .token(token))
                }
            case .open(let start):
                let node = Parser.BlockTree.open(.init(open: start, body: .init()))
                if let active = leading.active {
                    active.body.append(node)
                } else {
                    leading.topLevelPush(tree: node)
                }
            case .close(let end):
                if !leading.closeActiveSite(end: end) {
                    leading.topLevelPush(tree: .token(.close(end)))
                }
            }
        }
        return leading
    }
}

// MARK: - CONVERT -
extension Parser.BlockTree {
    var asSyntaxTree: Syntax {
        switch self {
        case .token(let tokenValue):
            switch tokenValue {
            case .char(let charToken):
                return Syntax.string(charToken.asStringRegion)
            case .string(let stringToken):
                return Syntax.string(stringToken)
            case .ident(let stringToken):
                return Syntax.cmd(.init(ident: stringToken, arguments: []))
            case .open(let charToken):
                return Syntax.invalid(.unclosedBlock(.init(open: charToken, body: [])))
            case .close(let charToken):
                return Syntax.invalid(.closeToken(charToken))
            }
        case .open(let open):
            return Syntax.invalid(.unclosedBlock(.init(
                open: open.open,
                body: open.body.elements.map({$0.asSyntaxTree})
            )))
        case .closed(let closed):
            return Syntax.enclosure(.init(
                open: closed.open,
                body: closed.body.elements.map({$0.asSyntaxTree}),
                close: closed.close
            ))
        case .fragment(let array):
            return Syntax.fragment(array.elements.map({$0.asSyntaxTree}))
        }
    }
}

// MARK: - DEBUG -
extension Parser.BlockTree: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .token(let tokenValue):
            switch tokenValue {
            case .char(let region):
                return PrettyTree("TokenTree.token.char(\(region.value.debugDescription))")
            case .ident(let region):
                return PrettyTree("TokenTree.token.ident(\(region.value.debugDescription))")
            case .string(let region):
                return PrettyTree("TokenTree.token.string(\(region.value.debugDescription))")
            case .open(let region):
                return PrettyTree("TokenTree.token.open(\(region.value.debugDescription))")
            case .close(let region):
                return PrettyTree("TokenTree.token.close(\(region.value.debugDescription))")
            }
        case .open(let open):
            return PrettyTree(name: "TokenTree.open", children: open.body.elements.map {$0.prettyTree})
        case .closed(let closed):
            return PrettyTree(name: "TokenTree.closed", children: closed.body.elements.map {$0.prettyTree})
        case .fragment(let arrayRef):
            return PrettyTree(name: "TokenTree.fragment", children: arrayRef.elements.map {$0.prettyTree})
        }
    }
}
