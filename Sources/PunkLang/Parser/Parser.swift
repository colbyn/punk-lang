//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

// MARK: - PARSER NAMESPACE -
struct Parser {}


// MARK: - PARSER TYPES -
extension Parser {
    struct Position {
        let line: Int
        let column: Int
    }
    struct Span {
        let line: Int
        let column: Int
        let range: NSRange
    }
    struct Ann<Value> {
        let span: Span
        let data: Value
    }
    typealias Text = Ann<String>
}


// MARK: - DEBUG -
extension Parser.Position: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(
            label: "Position",
            children: [
                .init(label: "line: \(line)"),
                .init(label: "column: \(column)"),
            ]
        )
    }
}
extension Parser.Span: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(
            label: "Span",
            children: [
                .init(label: "line: \(line)"),
                .init(label: "column: \(column)"),
                .init(label: "range: \(range)"),
            ]
        )
    }
}
extension Parser.Ann: ToDebugTree where Value: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(
            label: "Ann",
            children: [
                .init(label: "span", children: [span.debugTree]),
                .init(label: "value", children: [data.debugTree]),
            ]
        )
    }
}
