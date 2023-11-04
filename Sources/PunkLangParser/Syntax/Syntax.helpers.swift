//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation

extension Syntax {
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

extension Syntax.Region where Value == String {
    func join(other: Self) -> Self {
        Self(
            value: "\(self.value)\(other.value)",
            range: NSRange(location: self.range.location, length: self.range.length + other.range.length)
        )
    }
}
extension Syntax.Region where Value == Character {
    func join(other: Self) -> Syntax.Region<String> {
        Syntax.Region<String>(
            value: "\(self.value)\(other.value)",
            range: NSRange(location: self.range.location, length: self.range.length + other.range.length)
        )
    }
}
extension Syntax.Region where Value == String {
    func push(other: Syntax.Region<Character>) -> Syntax.Region<String> {
        Syntax.Region<String>(
            value: "\(self.value)\(other.value)",
            range: NSRange(location: self.range.location, length: self.range.length + other.range.length)
        )
    }
}
