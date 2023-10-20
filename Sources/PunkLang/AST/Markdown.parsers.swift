//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

extension Markdown {
    static var parser: Monad<Markdown> {
        Parser.oneOf(
            parsers: [
                { headerParser.map(Markdown.header) },
                { plainTextParser.map(Markdown.plainText) },
            ],
            ignoring: TextMonad.space
        )
    }
    static var plainTextParser: Monad<Parser.Text> {
        TextMonad.take(while: {!$0.isSpecialChar})
    }
    static var headerParser: Monad<Header> {
        func match(token: String) -> () -> Monad<Header> {
            {
                TextMonad
                    .match(prefix: token)
                    .and(Parser.many(Markdown.parser))
                    .map { hash, content in
                        Markdown.Header(hash: hash, content: content)
                    }
            }
        }
        return Parser.oneOf(
            parsers: [
                match(token: "#"),
                match(token: "##"),
                match(token: "###"),
                match(token: "####"),
                match(token: "#####"),
                match(token: "######"),
            ],
            ignoring: TextMonad.space
        )
    }
    static var linkParser: Monad<Link> {
        fatalError("TODO")
    }
    static var formattedParser: Monad<Formatted> {
        fatalError("TODO")
    }
    static var inlineCodeParser: Monad<InlineCode> {
        fatalError("TODO")
    }
    static var codeBlockParser: Monad<CodeBlock> {
        fatalError("TODO")
    }
    static var inlineMathParser: Monad<InlineMath> {
        fatalError("TODO")
    }
    static var mathBlockParser: Monad<MathBlock> {
        fatalError("TODO")
    }
    static var blockquoteParser: Monad<Blockquote> {
        fatalError("TODO")
    }
    static var horizontalRuleParser: Monad<HorizontalRule> {
        fatalError("TODO")
    }
}

fileprivate extension Character {
    var isSpecialChar: Bool {
        switch self {
        case "[", "]": return true
        case "(", ")": return true
        case "{", "}": return true
        case "#": return true
        case "\"", "'": return true
        default: return false
        }
    }
}
