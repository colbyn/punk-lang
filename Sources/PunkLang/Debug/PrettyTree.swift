//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

enum PrettyTree {
    case empty
    case value(String)
    case fragment([PrettyTree])
    case branch(Branch)
    case map(Map)
    struct Branch {
        let name: String
        let children: [PrettyTree]
    }
    struct KeyValue {
        let key: String
        let value: PrettyTree
    }
    struct Map {
        let name: String
        let fields: [KeyValue]
    }
}

protocol ToPrettyTree {
    var prettyTree: PrettyTree {get}
}

