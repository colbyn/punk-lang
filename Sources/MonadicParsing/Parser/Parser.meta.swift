//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

extension Parser {
    struct Position {
        let localIndex: String.Index
        let globalIndex: Int
        let globalLine: Int
        let globalColumn: Int
    }
    struct Span {
        let start: Position
        let end: Position
    }
}

extension Parser.Position {
    func to(_ end: Parser.Position) -> Parser.Span {
        Parser.Span(start: self, end: end)
    }
}

extension Parser.Span {
    func extend(end: Parser.Position) -> Parser.Span {
        Parser.Span(start: start, end: end)
    }
}
