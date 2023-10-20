//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

// MARK: - MONADIC PARSER API -
struct Monad<A> {
    let binder: (Stream) -> Output<A>
}

typealias CharMonad = Monad<String>
typealias TextMonad = Monad<Parser.Text>

// MARK: - INIT -
extension Monad {
    static func error(error: ParseError) -> Self {
        Monad { x in .err([error], x) }
    }
    static func pure(value: A) -> Self {
        Monad { s in .ok(value, s) }
    }
}
