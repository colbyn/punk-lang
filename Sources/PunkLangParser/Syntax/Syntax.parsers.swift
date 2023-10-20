//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/18/23.
//

import Foundation

extension Syntax {
    static var plainTextParser: Parser.IO<Self> {
        Parser.TextIO.collect { !$0.isHtmlSpecialChar && !$0.isMarkdownSpecialChar && !$0.isNewline }.map(Syntax.plainText)
    }
    static var symbolAsPlainTextParser: Parser.IO<Self> {
        Parser.TextIO.token("\n").map(Syntax.plainText)
    }
    static func parser(environment: Environment) -> Parser.IO<Self> {
        switch environment {
        case .default:
            return Parser.options(
                Syntax.Element.parser(environment: environment).map(Syntax.element),
                Syntax.Markdown.parser(environment: environment).map(Syntax.markdown),
                plainTextParser,
                symbolAsPlainTextParser
            )
        case .latex:
            return Parser.options(
                plainTextParser,
                symbolAsPlainTextParser
            )
        case .inline:
            return Parser.options(
                Syntax.Element.parser(environment: environment).map(Syntax.element),
                Syntax.Markdown.parser(environment: environment).map(Syntax.markdown),
                plainTextParser,
                symbolAsPlainTextParser
            )
        }
    }
}

// MARK: - PARSERS -
extension Syntax.Element.StartTag {
    static var parser: Parser.IO<Self> {
        let openAngle = Parser.TextIO.match(prefix: "<").allowTrailingSpace()
        let tagName = Parser.TextIO.collect { $0.isHtmlIdent }
        let closeAngle = Parser.TextIO.match(prefix: ">").allowLeadingSpace()
        return Parser
            .sequence(
                openAngle,
                tagName,
                closeAngle
            )
            .map { openAngle, tagName, closeAngle in
                Syntax.Element.StartTag(openAngle: openAngle, tagName: tagName, closeAngle: closeAngle)
            }
    }
}
extension Syntax.Element.EndTag {
    static func parser(matchTag tagName: String) -> Parser.IO<Self> {
        let openAngle = Parser.TextIO.match(prefix: "<")
        let forwardSlash = Parser.TextIO.match(prefix: "/")
        let tagName = Parser.TextIO.match(prefix: tagName)
        let closeAngle = Parser.TextIO.match(prefix: ">")
        return Parser
            .sequence(
                openAngle,
                forwardSlash,
                tagName,
                closeAngle
            )
            .map { openAngle, forwardSlash, tagName, closeAngle in
                Syntax.Element.EndTag(openAngle: openAngle, forwardSlash: forwardSlash, tagName: tagName, closeAngle: closeAngle)
            }
    }
}
extension Syntax.Element.VoidTag {
    static var parser: Parser.IO<Self> {
        let openAngle = Parser.TextIO.match(prefix: "<").allowTrailingSpace()
        let tagName = Parser.TextIO.collect { $0.isHtmlIdent }
        let forwardSlash = Parser.TextIO.match(prefix: "/").allowSpace()
        let closeAngle = Parser.TextIO.match(prefix: ">").allowLeadingSpace()
        return Parser
            .sequence(
                openAngle,
                tagName,
                forwardSlash,
                closeAngle
            )
            .map { openAngle, tagName, forwardSlash, closeAngle in
                Syntax.Element.VoidTag(openAngle: openAngle, tagName: tagName, forwardSlash: forwardSlash, closeAngle: closeAngle)
            }
    }
}
extension Syntax.Element {
    static func parser(environment: Syntax.Environment) -> Parser.IO<Self> {
        let element1 = Syntax.Element.StartTag.parser.allowAnyWhitespace()
            .then { start in
                let terminator = Syntax.Element.EndTag.parser(matchTag: "\(start.tagName.subsequence)").allowAnyWhitespace()
                return Parser
                    .many(Syntax.parser(environment: .default), until: terminator)
                    .and(terminator)
                    .map { x in
                        (start, x.0, x.1)
                    }
            }
            .map { (start, children, end) in
                Syntax.Element.pair(start: start, children: children, end: end)
            }
        let element2 = Syntax.Element.VoidTag.parser.map { Syntax.Element.single(void: $0) }
        return Parser.options(element1, element2)
    }
}
extension Syntax.Markdown.Header {
    static var parser: Parser.IO<Self> {
        let hashVariants = Parser.options(
            Parser.TextIO.token("######"),
            Parser.TextIO.token("#####"),
            Parser.TextIO.token("####"),
            Parser.TextIO.token("###"),
            Parser.TextIO.token("##"),
            Parser.TextIO.token("#")
        )
        let rest = Parser.untilEndOfLine(do: Syntax.parser(environment: .inline))
        return hashVariants.leftward(Parser.space).and(rest).map { hash, content in
            Syntax.Markdown.Header(hash: hash, content: content)
        }
    }
}
extension Syntax.Markdown.FormatBetween {
    static var parser: Parser.IO<Self> {
        let emphasis = Parser.options(
            Parser.TextIO.token("**"),
            Parser.TextIO.token("*"),
            Parser.TextIO.token("__"),
            Parser.TextIO.token("_")
        )
        let highlight = Parser.options(
            Parser.TextIO.token("==")
        )
        let script = Parser.options(
            Parser.TextIO.token("^"),
            Parser.TextIO.token("~")
        )
        let seq = Parser.options(
            emphasis,
            highlight,
            script
        )
        return seq
            .then{ seq in
                let terminator = Parser.TextIO.token("\(seq.subsequence)")
                return Parser
                    .many(Syntax.parser(environment: .inline), until: terminator)
                    .and(terminator)
                    .map { xs in (seq, xs.0, xs.1) }
                    
            }
            .map { (open, content, close) in
                Syntax.Markdown.FormatBetween(open: open, content: content, close: close)
            }
    }
}
extension Syntax.Markdown {
    static func parser(environment: Syntax.Environment) -> Parser.IO<Self> {
        switch environment {
        case .default: return Parser.options(
                Syntax.Markdown.Header.parser.map(Syntax.Markdown.header),
                Syntax.Markdown.FormatBetween.parser.map(Syntax.Markdown.formatBetween)
            )
        case .inline: return Parser.options(
            Syntax.Markdown.FormatBetween.parser.map(Syntax.Markdown.formatBetween)
        )
        case .latex:
            return Parser.IO.fail()
        }
    }
}
extension Syntax.Latex.Enclosed {
    static var parser: Parser.IO<Self> {
        fatalError("TODO")
    }
}
extension Syntax.Latex.Cmd {
    static var parser: Parser.IO<Self> {
        fatalError("TODO")
    }
}
extension Syntax.Latex.Environment.Begin {
    static var parser: Parser.IO<Self> {
        fatalError("TODO")
    }
}
extension Syntax.Latex.Environment.End {
    static var parser: Parser.IO<Self> {
        fatalError("TODO")
    }
}
extension Syntax.Latex.Environment {
    static var parser: Parser.IO<Self> {
        fatalError("TODO")
    }
}

fileprivate extension Character {
    var isHtmlSpecialChar: Bool {
        switch self {
        case "<", ">": return true
        case "/": return true
        default: return false
        }
    }
    var isMarkdownSpecialChar: Bool {
        switch self {
        case "#": return true
        default: return false
        }
    }
    var isHtmlIdent: Bool {
        !isHtmlSpecialChar && !self.isWhitespace
    }
    var latexSpecialChar: Bool {
        switch self {
        case "\\": return true
        case "{", "}": return true
        default: return false
        }
    }
}
