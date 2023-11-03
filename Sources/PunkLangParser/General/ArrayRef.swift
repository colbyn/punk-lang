//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation

final class ArrayRef<Element> {
    internal var elements: [Element] = []
    var first: Element? { self.elements.first }
    var last: Element? { self.elements.last }
    init() {
        self.elements = []
    }
    init(from array: [Element]) {
        self.elements = array
    }
    subscript(index: Int) -> Element? {
        get {
            if elements.count <= index + 1 {
                return elements[index]
            }
            return nil
        }
    }
    func append(_ element: Element) {
        self.elements.append(element)
    }
}
