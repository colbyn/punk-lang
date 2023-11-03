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
}

