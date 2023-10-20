//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

struct Indexed<Value> {
    let index: Int
    let value: Value
}
struct Stream {
    let line: Int
    let column: Int
    let cursor: Int
    let source: NSString
}

// MARK: - INIT -
extension Stream {
    init(from source: String) {
        self.line = 0
        self.column = 0
        self.cursor = 0
        self.source = NSString(string: source)
    }
}

// MARK: - API -
extension Stream {
    var view: String {
        source.substring(with: NSRange(location: cursor, length: source.length - cursor))
    }
    func head(length: Int = 1) -> Output<String> {
        if self.view.isEmpty {
            return .err([.empty], self)
        }
        if (0...source.length).contains(cursor + length) {
            let res = self.source.substring(with: NSRange(location: self.cursor, length: length))
            var line = self.line
            var column = self.column
            for char in res {
                if char.isNewline {
                    line = line + 1
                    column = 0
                    continue
                }
                column = column + 1
            }
            let new = Stream(
                line: line,
                column: column,
                cursor: self.cursor + length,
                source: source
            )
            return .ok(res, new)
        }
        return .err([.empty], self)
    }
    func take(while f: (Character) -> Bool) -> Output<Indexed<String>> {
        if self.view.isEmpty {
            return .err([.empty], self)
        }
        let start = cursor
        var line = self.line
        var column = self.column
        var cursor = self.cursor
        var result: String = ""
        for char in view {
            if !f(char) {
                break
            }
            result = "\(result)\(char)"
        }
        if result.isEmpty {
            return .err([.noMatch], self)
        }
        cursor = cursor + result.count
        Stream.update(line: &line, column: &column, for: result)
        let new = Stream(line: line, column: column, cursor: cursor, source: source)
        return .ok(Indexed(index: start, value: result), new)
    }
    func takePrefix(match prefix: String) -> Output<String> {
        if self.view.isEmpty {
            return .err([.empty], self)
        }
        let view = view
        var line = self.line
        var column = self.column
        if view.hasPrefix(prefix) {
            Stream.update(line: &line, column: &column, for: prefix)
            let cursor = cursor + prefix.count
            let new = Stream(line: line, column: column, cursor: cursor, source: source)
            return .ok(prefix, new)
        }
        return .err([.noMatch], self)
    }
}

// MARK: - DEBUG -
extension Stream: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(
            label: "Stream",
            children: [
                .init(label: "line: \(line)"),
                .init(label: "column: \(column)"),
                .init(label: "cursor: \(cursor)"),
                view.isEmpty ? .init(label: "view: \"\"") : .init(label: "view:\n\(view)")
            ]
        )
    }
}

// MARK: - HELPERS -
extension Stream {
    static func update(line: inout Int, column: inout Int, for span: String) {
        for char in span {
            if char.isNewline {
                line = line + 1
                column = 0
                continue
            }
            column = column + 1
        }
    }
}

