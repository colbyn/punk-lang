//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

extension Array {
    mutating func replaceExpand<C>(index: Self.Index, with newElements: C) where Element == C.Element, C : Collection {
        self.replaceSubrange(index...index, with: newElements)
    }
    func with(append newElement: Element) -> Self {
        var xs = self
        xs.append(newElement)
        return xs
    }
    func with(tail: [Element]) -> Self {
        var xs = self
        xs.append(contentsOf: tail)
        return xs
    }
    func firstMap<Result>(where f: (Self.Element) -> Result?) -> Result? {
        for element in self {
            if let result = f(element) {
                return result
            }
        }
        return nil
    }
    mutating func safePopFirst() -> Element? {
        if self.isEmpty { return nil }
        return self.removeFirst()
    }
}
