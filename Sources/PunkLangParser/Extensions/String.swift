//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/19/23.
//

import Foundation

extension String {
    func truncate(limit: Int) -> String {
        if self.count > limit {
            let trimmed = self.prefix(limit)
            if trimmed.starts(with: "\"") {
                return "\(trimmed)\"…"
            }
            return String("\(trimmed)…")
        }
        return self
    }
    mutating func safePopFirstChar() -> Character? {
        if self.isEmpty {
            return nil
        }
        return self.removeFirst()
    }
    func join(with other: String) -> String {
        return "\(self)\(other)"
    }
    func join(with other: Character) -> String {
        return "\(self)\(other)"
    }
}

