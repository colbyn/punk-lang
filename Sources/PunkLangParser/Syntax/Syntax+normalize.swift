//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation

extension Syntax {
    func normalize() -> Self {
        switch self {
        case .string:
            return self
        case .cmd(let cmd):
            return .cmd(cmd.normalize())
        case .enclosure(let enclosure):
            return .enclosure(enclosure.normalize())
        case .invalid(let invalid):
            return .invalid(invalid.normalize())
        case .fragment(let array):
            return .fragment(array.normalize())
        }
    }
}
extension Syntax.Cmd {
    func normalize() -> Self {
        let arguments = self.arguments.map { $0.normalize() }
        return .init(ident: ident, arguments: arguments)
    }
}
extension Syntax.Enclosure {
    func normalize() -> Self {
        let body = self.body.normalize()
        return Self(open: open, body: body, close: close)
    }
}
extension Syntax.Unclosed {
    func normalize() -> Self {
        let body = self.body.normalize()
        return Self(open: open, body: body)
    }
}
extension Syntax.Invalid {
    func normalize() -> Self {
        switch self {
        case .unclosedBlock(let unclosed):
            return .unclosedBlock(unclosed.normalize())
        case .closeToken:
            return self
        }
    }
}

fileprivate extension Array<Syntax> {
    func normalize() -> [Syntax] {
        var leading: [Syntax] = []
        var trailing = self.map { $0.normalize() }
        loop: while case .some(let value) = trailing.safePopFirst() {
            if var cmd = value.asCmd {
                let rightward = trailing
                    .consume(satisfy: {$0.isEnclosure || $0.isWhitespace})
                var done = false
                inner: for node in rightward {
                    if let enclousre = node.asEnclosure, !done {
                        cmd.arguments.append(enclousre)
                        continue inner
                    } else {
                        done = true
                        trailing.insert(node, at: 0)
                        break inner
                    }
                }
                leading.append(.cmd(cmd))
                continue loop
            }
            // MARK: - DONE -
            leading.append(value)
        }
        return leading
    }
    mutating func consume(satisfy pred: (Syntax) -> Bool) -> [Syntax] {
        var xs: [Syntax] = []
        while let node = self.safePopFirst() {
            if pred(node) {
                xs.append(node)
            } else {
                self.insert(node, at: 0)
                break
            }
        }
        return xs
    }
}
