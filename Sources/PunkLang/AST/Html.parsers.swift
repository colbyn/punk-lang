//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation


extension Html {
    static var parser: Monad<Html> {
        fatalError("TODO")
    }
    static var markdownParser: Monad<Html> {
        fatalError("TODO")
    }
    static var elementParser: Monad<Html.Element> {
        fatalError("TODO")
    }
}
extension Html.Element {
    static var attributeParser: Monad<Html.Element.Attribute> {
        let keyvalue = Parser
            .either(
                left: TextMonad.word,
                right: Parser.betweenAnyQuote {quote in TextMonad.take(while: {$0 != quote})}
            )
            .map {
                switch $0 {
                case .left(let value):
                    return Html.Element.InQuoteOpt(openQuote: nil, value: value, closeQuote: nil)
                case .right(let value):
                    return Html.Element.InQuoteOpt(openQuote: value.0, value: value.1, closeQuote: value.2)
                }
            }
        let eq = TextMonad.match(prefix: "=")
        return keyvalue
            .then { key in eq.map {eq in (key, eq)} }
            .then { key, eq in keyvalue.map {value in (key, eq, value)} }
            .map { key, eq, value in Html.Element.Attribute(key: key, eq: eq, value: value) }
    }
    static var voidElementParser: Monad<Html.Element.VoidElement> {
        fatalError("TODO")
    }
    static var blockElementParser: Monad<Html.Element.BlockElement> {
        fatalError("TODO")
    }
}
extension Html.Element.BlockElement {
    static var openTagParser: Monad<Html.Element.BlockElement.OpenTag> {
        TextMonad
            .match(prefix: "<")
            .then { openAngle in
                TextMonad.word.map { id in
                    (openAngle, id)
                }
            }
            .keepLeft(TextMonad.space)
            .then { openAngle, id in
                Parser.many(Html.Element.attributeParser).map { attrs in
                    (openAngle, id, attrs)
                }
            }
            .keepLeft(TextMonad.space)
            .then { openAngle, id, attrs in
                TextMonad.match(prefix: ">").map { closeAngle in
                    Html.Element.BlockElement.OpenTag(
                        openAngle: openAngle,
                        tagName: id,
                        attributes: attrs,
                        closeAngle: closeAngle
                    )
                }
            }
    }
    static var closeTagParser: Monad<Html.Element.BlockElement.OpenTag> {
        fatalError("TODO")
    }
}

fileprivate extension Character {
    var isSpecialChar: Bool {
        switch self {
        case "<", ">": return true
        case "/": return true
        case "=": return true
        case "\"", "'": return true
        default: return false
        }
    }
}
fileprivate extension TextMonad {
    static var word: TextMonad {
        TextMonad { s1 in
            s1  .take { $0.isLetter || $0.isNumber }
                .mapWithContext { id, s2 in
                    return Parser.Text(
                        span: .init(line: s1.line, column: s1.column, range: .init(location: s1.column, length: s2.cursor - s1.cursor)),
                        data: id.value
                    )
                }
        }
    }
}
