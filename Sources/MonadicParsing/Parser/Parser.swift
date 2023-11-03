//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

/// All exported symbols are namespaced under 'Parser'.
public struct Parser {}

extension Parser {
    public static func execute<A>(parser: IO<A>, source: String) -> Parser.State<A> {
        parser.binder(Parser.Text(string: source))
    }
}
