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
    static func latexParser(environment: Environment) -> Parser.IO<Self> {
        let block = Parser.TextIO.token("$$").allowAnyWhitespace()
        let inline = Parser.TextIO.token("$").allowAnyWhitespace()
        let parser1 = Parser
            .enclosedBetween(start: block, content: Syntax.Latex.parser, end: block)
            .map {start, content, end in
                Self.latex(start: start, content: content, end: end)
            }
        let parser2 = Parser
            .enclosedBetween(start: inline, content: Syntax.Latex.parser, end: inline)
            .map {start, content, end in
                Self.latex(start: start, content: content, end: end)
            }
        switch environment {
        case .default:
            return Parser.options(parser1, parser2)
        case .inline:
            return Parser.options(parser2)
        }
    }
    static func parser(environment: Environment) -> Parser.IO<Self> {
        switch environment {
        case .default:
            return Parser.options(
                Syntax.Element.parser(environment: environment).map(Syntax.element),
                Syntax.Markdown.parser(environment: environment).map(Syntax.markdown),
                latexParser(environment: .default),
                plainTextParser,
                symbolAsPlainTextParser
            )
        case .inline:
            return Parser.options(
                Syntax.Element.parser(environment: environment).map(Syntax.element),
                Syntax.Markdown.parser(environment: environment).map(Syntax.markdown),
                latexParser(environment: .inline),
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
        let attributes = Parser.many(Syntax.Element.Attribute.parser).allowSpace()
        let closeAngle = Parser.TextIO.match(prefix: ">").allowLeadingSpace()
        return Parser
            .sequence(
                openAngle,
                tagName,
                attributes,
                closeAngle
            )
            .map { openAngle, tagName, attributes, closeAngle in
                Syntax.Element.StartTag(openAngle: openAngle, tagName: tagName, attributes: attributes, closeAngle: closeAngle)
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
        let attributes = Parser.many(Syntax.Element.Attribute.parser)
        let forwardSlash = Parser.TextIO.match(prefix: "/").allowSpace()
        let closeAngle = Parser.TextIO.match(prefix: ">").allowLeadingSpace()
        return Parser
            .sequence(
                openAngle,
                tagName,
                attributes,
                forwardSlash,
                closeAngle
            )
            .map { openAngle, tagName, attributes, forwardSlash, closeAngle in
                Syntax.Element.VoidTag(
                    openAngle: openAngle,
                    tagName: tagName,
                    attributes: attributes,
                    forwardSlash: forwardSlash,
                    closeAngle: closeAngle
                )
            }
    }
}
extension Syntax.Element.AttributeItem {
    static var parser: Parser.IO<Self> {
        let word = Parser.TextIO.collect(whileTrue: {$0.isWord})
        let quoteChar: Character = "\""
        let quote = Parser.TextIO.token("\(quoteChar)")
        let parser1 = quote
            .and(Parser.TextIO.collect(whileTrue: {$0 != quoteChar}), quote)
            .map { open, content, close in
                Self(openQuote: open, content: content, closeQuote: close)
            }
        let parser2 = word.map({Self(openQuote: nil, content: $0, closeQuote: nil)})
        return Parser.options(parser1, parser2)
    }
}
extension Syntax.Element.Attribute {
    static var parser: Parser.IO<Self> {
        return Parser
            .sequence(
                Syntax.Element.AttributeItem.parser,
                Parser.TextIO.token("=").allowSpace(),
                Syntax.Element.AttributeItem.parser
            )
            .map { key, eq, value in
                Self(key: key, eq: eq, value: value)
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
        let rest = Parser.untilEndOfLine(do: Syntax.parser(environment: .inline)).leftward(Parser.try(Parser.TextIO.token("\n")))
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
        }
    }
}
extension Syntax.Latex.Enclosed {
    static var parser: Parser.IO<Self> {
        let parser1 = Parser
            .enclosedBetween(
                start: Parser.TextIO.token("{"),
                content: Syntax.Latex.parser,
                end: Parser.TextIO.token("}")
            )
            .map { open, content, close in
                Self(open: open, content: content, close: close)
            }
        let parser2 = Parser
            .enclosedBetween(
                start: Parser.TextIO.token("["),
                content: Syntax.Latex.parser,
                end: Parser.TextIO.token("]")
            )
            .map { open, content, close in
                Self(open: open, content: content, close: close)
            }
        return Parser.options(parser1, parser2)
    }
}
extension Syntax.Latex.Cmd {
    static var parser: Parser.IO<Self> {
        let slash = Parser.TextIO.token("\\")
        let ident = Parser.TextIO.collect(whileTrue: {$0.isWord})
        let arguments = Parser.many(Syntax.Latex.Enclosed.parser)
        return Parser.sequence(slash, ident, arguments).map { slash, ident, arguments in
            Self(slash: slash, ident: ident, arguments: arguments)
        }
    }
}
extension Syntax.Latex.Environment.Begin {
    static var parser: Parser.IO<Self> {
        let slash = Parser.TextIO.token("\\")
        let begin = Parser.TextIO.token("begin")
        let open = Parser.TextIO.token("{")
        let name = Parser.TextIO.collect(whileTrue: {$0.isWord})
        let close = Parser.TextIO.token("}")
        let arguments = Parser.many(Syntax.Latex.Enclosed.parser)
        let parser = Parser
            .sequence(
                slash,
                begin,
                open,
                name,
                close,
                arguments
            )
            .map { slash, begin, open, name, close, arguments in
                Self(slash: slash, begin: begin, open: open, name: name, close: close, arguments: arguments)
            }
        return parser
    }
}
extension Syntax.Latex.Environment.End {
    static var parser: Parser.IO<Self> {
        let slash = Parser.TextIO.token("\\")
        let end = Parser.TextIO.token("end")
        let open = Parser.TextIO.token("{")
        let name = Parser.TextIO.collect(whileTrue: {$0.isWord})
        let close = Parser.TextIO.token("}")
        let parser = Parser
            .sequence(
                slash,
                end,
                open,
                name,
                close
            )
            .map { slash, end, open, name, close in
                Self(slash: slash, end: end, open: open, name: name, close: close)
            }
        return parser
    }
}
extension Syntax.Latex.Environment {
    static var parser: Parser.IO<Self> {
        let begin = Syntax.Latex.Environment.Begin.parser
        let end = Syntax.Latex.Environment.End.parser
        let content = Parser.many(Syntax.Latex.parser, until: end)
        let parser = Parser
            .sequence(begin, content, end)
            .map { begin, content, end in
                Self(begin: begin, content: content, end: end)
            }
        return parser
    }
}
extension Syntax.Latex {
    static var plainTextParser: Parser.IO<Self> {
        Parser.TextIO.collect { !$0.latexSpecialChar }.map(Self.plainText)
    }
    static var symbolAsPlainTextParser: Parser.IO<Self> {
        Parser.TextIO.token("\n").map(Self.plainText)
    }
    static var parser: Parser.IO<Self> {
        let cmd = Syntax.Latex.Cmd.parser.map(Self.cmd)
        let environment = Syntax.Latex.Environment.parser.map(Self.environment)
//        let enclosed = Syntax.Latex.Enclosed.parser.map(Self.enclosed)
        let parser = Parser.options(symbolAsPlainTextParser, environment, cmd, plainTextParser)
        return parser
    }
}

fileprivate extension Character {
    var isHtmlSpecialChar: Bool {
        switch self {
        case "<", ">": return true
        case "/": return true
        case "$": return true
        default: return false
        }
    }
    var isWord: Bool {
        self.isNumber || self.isLetter
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
        case "{": return true
        case "}": return true
        default: return false
        }
    }
}
