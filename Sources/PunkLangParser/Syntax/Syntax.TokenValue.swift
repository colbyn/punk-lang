import Foundation
import PrettyTree

extension Syntax {
    enum TokenValue {
        case char(CharToken)
        case string(StringToken)
        case ident(StringToken)
        case open(CharToken)
        case close(CharToken)
    }
}

extension Syntax.TokenValue {
    init(char: Character, location: Int) {
        switch char {
        case "{":
            self = .open(.init(value: char, range: NSRange(location: location, length: 1)))
        case "}":
            self = .close(.init(value: char, range: NSRange(location: location, length: 1)))
        case "\\":
            self = .ident(.init(value: String(char), range: NSRange(location: location, length: 1)))
        default:
            self = .char(.init(value: char, range: NSRange(location: location, length: 1)))
        }
    }
    static func tokenize(source: String) -> [Self] {
        var leading: [Self] = []
        var trailing = source
        var cursor: Int = 0
        while case .some(let next) = trailing.safePopFirstChar() {
            let next = Self(char: next, location: cursor)
            switch leading.popLast().map({$0.join(other: next)}) {
            case .some((let left, .some(let right))):
                leading.append(left)
                leading.append(right)
            case .some((let left, .none)):
                leading.append(left)
            case .none:
                leading.append(next)
            }
            cursor += 1
        }
        return leading
    }
    func join(other: Self) -> (Self, Self?) {
        switch self {
        case .char(let char1):
            switch other {
            case .char(let char2):
                return (.string(char1.join(other: char2)), nil)
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
                return (.string(string1.push(other: char2)), nil)
            case .string(let string2):
                return (.string(string1.join(other: string2)), nil)
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
                return (.ident(string1.push(other: char2)), nil)
            case .string:
                return (self, other)
            case .ident(let string2):
                return (.ident(string1.join(other: string2)), nil)
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
extension Syntax.TokenValue: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .char(let region):
            return PrettyTree(".char(\(region.value.debugDescription))")
        case .ident(let region):
            return PrettyTree(".ident(\(region.value.debugDescription))")
        case .string(let region):
            return PrettyTree(".string(\(region.value.debugDescription))")
        case .open(let region):
            return PrettyTree(".open(\(region.value.debugDescription))")
        case .close(let region):
            return PrettyTree(".close(\(region.value.debugDescription))")
        }
    }
}
