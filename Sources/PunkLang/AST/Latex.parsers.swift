//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

extension Latex {
    static var parser: Monad<Latex> {
        fatalError("TODO")
    }
    static var plainTextParser: Monad<Parser.Text> {
        fatalError("TODO")
    }
    static var symbolParser: Monad<Parser.Text> {
        fatalError("TODO")
    }
    static var enclosedParser: Monad<Latex.Enclosed> {
        fatalError("TODO")
    }
    static var cmdParser: Monad<Cmd> {
        fatalError("TODO")
    }
}

fileprivate extension TextMonad {
    static var latexIdent: TextMonad {
        TextMonad { s1 in
            s1  .take { $0.isLetter }
                .mapWithContext { id, s2 in
                    return Parser.Text(
                        span: .init(line: s1.line, column: s1.column, range: .init(location: s1.column, length: s2.cursor - s1.cursor)),
                        data: id.value
                    )
                }
        }
    }
}


