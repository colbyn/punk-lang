//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

extension Parser {
    public struct Text {
        let span: Span
        let subsequence: String.SubSequence
    }
    public typealias Token = Parser.Text
}

extension Parser.Text {
    public init(string: String) {
        if string.isEmpty {
            self.span = .init(
                start: .init(localIndex: "".startIndex, globalIndex: 0, globalLine: 0, globalColumn: 0),
                end: .init(localIndex: "".endIndex, globalIndex: 0, globalLine: 0, globalColumn: 0)
            )
            self.subsequence = ""
            return
        }
        let startPosition = Parser.Position(localIndex: string.startIndex, globalIndex: 0, globalLine: 0, globalColumn: 0)
        let endIndex = string.index(string.startIndex, offsetBy: string.count - 1, limitedBy: string.endIndex)!
        var endCursor = 0
        var endLine = 0
        var endColumn = 0
        for char in string {
            endCursor += 1
            endColumn += 1
            if char.isNewline {
                endLine += 1
                endColumn = 0
            }
        }
        let endPosition = Parser.Position(localIndex: endIndex, globalIndex: endCursor, globalLine: endLine, globalColumn: endColumn)
        self.span = Parser.Span(start: startPosition, end: endPosition)
        self.subsequence = string[string.startIndex...endIndex]
    }
    public func advance(by distance: Int) -> (Parser.Text, Parser.Text)? {
        let startIndex = subsequence.startIndex
        let endIndex = subsequence.endIndex
        guard let middleIndex = subsequence.index(startIndex, offsetBy: distance, limitedBy: endIndex) else {
            return nil
        }
        let left = subsequence.prefix(upTo: middleIndex)
        let right = subsequence.suffix(from: middleIndex)
        var cursor = self.span.start.globalIndex
        var line = self.span.start.globalLine
        var column = self.span.start.globalColumn
        for char in left {
            cursor += 1
            column += 1
            if char.isNewline {
                line += 1
                column = 0
            }
        }
        let middlePosition = Parser.Position(localIndex: middleIndex, globalIndex: cursor, globalLine: line, globalColumn: column)
        let leftSpan = Parser.Span(
            start: self.span.start,
            end: middlePosition
        )
        let rightSpan = Parser.Span(
            start: middlePosition,
            end: self.span.end
        )
        return (Parser.Text(span: leftSpan, subsequence: left), Parser.Text(span: rightSpan, subsequence: right))
    }
    public func collect(whileTrue pred: (Character) -> Bool) -> (Parser.Text, Parser.Text)? {
        let middleIndex = subsequence.firstIndex(where: {!pred($0)}) ?? subsequence.endIndex
        let left = subsequence.prefix(upTo: middleIndex)
        let right = subsequence.suffix(from: middleIndex)
        var cursor = self.span.start.globalIndex
        var line = self.span.start.globalLine
        var column = self.span.start.globalColumn
        for char in left {
            cursor += 1
            column += 1
            if char.isNewline {
                line += 1
                column = 0
            }
        }
        let middlePosition = Parser.Position(localIndex: middleIndex, globalIndex: cursor, globalLine: line, globalColumn: column)
        let leftSpan = Parser.Span(
            start: self.span.start,
            end: middlePosition
        )
        let rightSpan = Parser.Span(
            start: middlePosition,
            end: self.span.end
        )
        if left.isEmpty {
            return nil
        }
        return (Parser.Text(span: leftSpan, subsequence: left), Parser.Text(span: rightSpan, subsequence: right))
    }
    public func splitPrefix(string: String) -> (Parser.Text, Parser.Text)? {
        guard let (prefix, rest) = self.advance(by: string.count) else {return nil}
        if prefix.subsequence == string {
            return (prefix, rest)
        }
        return nil
    }
}

