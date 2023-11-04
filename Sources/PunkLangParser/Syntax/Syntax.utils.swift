//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 11/3/23.
//

import Foundation

extension Syntax {
    var asEnclosure: Syntax.Enclosure? {
        switch self {
        case .enclosure(let x): return x
        default: return nil
        }
    }
    var asString: Parser.StringToken? {
        switch self {
        case .string(let x): return x
        default: return nil
        }
    }
    var asCmd: Syntax.Cmd? {
        switch self {
        case .cmd(let x): return x
        default: return nil
        }
    }
    var isWhitespace: Bool {
        self.asString?.value.allSatisfy({$0.isWhitespace}) ?? false
    }
    var isEnclosure: Bool {
        self.asEnclosure.isSome == true
    }
}
