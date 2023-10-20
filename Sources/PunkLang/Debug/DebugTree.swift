//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

enum DebugTree {
    case branch(Branch)
    //    case product(ProductType)
    case fragment([DebugTree])
    case label(String)
    case empty
    public struct Branch {
        let label: String
        let children: [DebugTree]
    }
    public struct ProductType {
        let name: String
        let fields: [KeyValue]
    }
    public struct KeyValue {
        let key: String
        let value: String
    }
}

extension DebugTree {
    static let todo: DebugTree = DebugTree(label: "TODO")
    init(label: String, children: [DebugTree]) {
        self = .branch(.init(label: label, children: children))
    }
    init(fragment: [DebugTree]) {
        self = .fragment(fragment)
    }
    init(label: String) {
        self = .label(label)
    }
    func print() {
        if let result = self.format(with: .init()) {
            Swift.print(result)
            return ()
        }
        Swift.print("PRINT FAILED")
    }
}

protocol ToDebugTree {
    var debugTree: DebugTree {get}
}
extension DebugTree: ToDebugTree {
    var debugTree: DebugTree { self }
}
extension Character: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "'\(self)'")
    }
}
extension String: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: self.debugDescription)
    }
}
extension Array: ToDebugTree where Array.Element: ToDebugTree {
    var debugTree: DebugTree {
        let fragment = self.map({$0.debugTree})
        return DebugTree.fragment(fragment)
    }
}
extension NSRange: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "NSRange", children: [
            .init(label: "location: \(location)"),
            .init(label: "length: \(length)"),
        ])
    }
}
