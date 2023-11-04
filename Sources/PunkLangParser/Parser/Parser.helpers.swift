//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation

extension Parser {
    typealias CharToken = Region<Character>
    typealias StringToken = Region<String>
    struct Position {
        let index: Int
    }
    struct Region<Value> {
        let value: Value
        let range: NSRange
    }
}

extension Parser.Region where Value == String {
    func join(other: Self) -> Self {
        Self(
            value: "\(self.value)\(other.value)",
            range: NSRange(location: self.range.location, length: self.range.length + other.range.length)
        )
    }
}
extension Parser.Region where Value == Character {
    func join(other: Self) -> Parser.Region<String> {
        Parser.Region<String>(
            value: "\(self.value)\(other.value)",
            range: NSRange(location: self.range.location, length: self.range.length + other.range.length)
        )
    }
    var asStringRegion: Parser.Region<String> {
        Parser.Region<String>(value: String(self.value), range: self.range)
    }
}
extension Parser.Region where Value == String {
    func push(other: Parser.Region<Character>) -> Parser.Region<String> {
        Parser.Region<String>(
            value: "\(self.value)\(other.value)",
            range: NSRange(location: self.range.location, length: self.range.length + other.range.length)
        )
    }
}
