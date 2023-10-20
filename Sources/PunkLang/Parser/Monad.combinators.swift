//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

extension TextMonad {
    static func match(prefix: String) -> TextMonad {
        TextMonad { s1 in
            let starting = s1
            switch s1.takePrefix(match: prefix) {
            case .ok(let value, let s2):
                let text = Parser.Text(
                    span: .init(
                        line: starting.line,
                        column: starting.column,
                        range: NSRange(location: starting.cursor, length: s2.cursor - starting.cursor)
                    ),
                    data: value
                )
                return .ok(text, s2)
            case .err(let e, let s2): return .err(e, s2)
            }
        }
    }
    static func take(while pred: @escaping (Character) -> Bool) -> TextMonad {
        TextMonad { s1 in
            var stream = s1
            var consumed: String = ""
        loop: while true {
            switch stream.head(length: 1) {
            case .ok(let val, let next):
                for char in val {
                    if !pred(char) {
                        break loop
                    }
                }
                stream = next
                consumed = "\(consumed)\(val)"
                continue loop
            case .err(_, let s2):
                stream = s2
                break loop
            }
        }
            if consumed.isEmpty {
                return .err([.empty], s1)
            }
            let expr: Parser.Text = Parser.Text(
                span: .init(line: s1.line, column: s1.column, range: .init(location: s1.cursor, length: stream.cursor - s1.cursor)),
                data: consumed
            )
            return .ok(expr, stream)
        }
    }
    static func head(length: Int) -> TextMonad {
        TextMonad { s1 in
            s1.head(length: length).andThen { str, s2 in
                let value = Parser.Text(
                    span: .init(line: s1.line, column: s1.column, range: .init(location: s1.cursor, length: str.count)),
                    data: str
                )
                return .ok(value, s2)
            }
        }
    }
    static var head: Self {
        Self.head(length: 1)
    }
    static var anyWhitespace: TextMonad {
        TextMonad
            .take { $0.isWhitespace }
            .recover { stream in
                Parser.Text(
                    span: .init(line: stream.line, column: stream.column, range: .init(location: stream.cursor, length: 0)),
                    data: ""
                )
            }
    }
    static var space: TextMonad {
        TextMonad
            .take { $0.isWhitespace && !$0.isNewline }
            .recover { stream in
                Parser.Text(
                    span: .init(line: stream.line, column: stream.column, range: .init(location: stream.cursor, length: 0)),
                    data: ""
                )
            }
    }
    static var newline: TextMonad {
        TextMonad.take { $0.isNewline }
    }
}


