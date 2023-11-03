//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation
import PrettyTree

extension Syntax {
    enum Token {
        case char(Character)
        case string(String)
        case ident(String)
        case open
        case close
    }
}

// MARK: - PARSER -
extension Syntax.Token {
    init(char: Character) {
        switch char {
        case "{":
            self = .open
        case "}":
            self = .close
        case "\\":
            self = .ident("\\")
        default:
            self = .char(char)
        }
    }
    static func tokenize(source: String) -> [Self] {
        var leading: [Self] = []
        var trailing = source
        while case .some(let next) = trailing.safePopFirstChar() {
            let next = Self(char: next)
            switch leading.popLast().map({$0.join(other: next)}) {
            case .some((let left, .some(let right))):
                leading.append(left)
                leading.append(right)
            case .some((let left, .none)):
                leading.append(left)
            case .none:
                leading.append(next)
            }
        }
        return leading
    }
    func join(other: Self) -> (Self, Self?) {
        switch self {
        case .char(let char1):
            switch other {
            case .char(let char2):
                return (.string("\(char1)\(char2)"), nil)
            case .string:
                return (self, other)
            case .ident:
                return (self, other)
            case .open:
                return (self, other)
            case .close:
                return (self, other)
            }
        case .string(let string1):
            switch other {
            case .char(let char2):
                return (.string(string1.join(with: char2)), nil)
            case .string(let string2):
                return (.string(string1.join(with: string2)), nil)
            case .ident:
                return (self, other)
            case .open:
                return (self, other)
            case .close:
                return (self, other)
            }
        case .ident(let string1):
            switch other {
            case .char(let char2):
                return (.ident(string1.join(with: char2)), nil)
            case .string:
                return (self, other)
            case .ident(let string2):
                return (.ident(string1.join(with: string2)), nil)
            case .open:
                return (self, other)
            case .close:
                return (self, other)
            }
        case .open:
            switch other {
            case .char:
                return (self, other)
            case .string:
                return (self, other)
            case .ident:
                return (self, other)
            case .open:
                return (self, other)
            case .close:
                return (self, other)
            }
        case .close:
            switch other {
            case .char:
                return (self, other)
            case .string:
                return (self, other)
            case .ident:
                return (self, other)
            case .open:
                return (self, other)
            case .close:
                return (self, other)
            }
        }
    }
}

// MARK: - DEBUG -
extension Syntax.Token: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .string(let string):
            return PrettyTree(".string(\(string.debugDescription))")
        case .ident(let string):
            return PrettyTree(".ident(\(string.debugDescription))")
        case .open:
            return PrettyTree(".open")
        case .close:
            return PrettyTree(".close")
        case .char(let char):
            return PrettyTree(".char('\(char)')")
        }
    }
}
