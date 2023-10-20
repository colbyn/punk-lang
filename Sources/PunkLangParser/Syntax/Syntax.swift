//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/18/23.
//

import Foundation

enum Syntax {
    typealias Token = Parser.Text
    typealias Text = Parser.Text
    case plainText(Text)
    case element(Element)
    case markdown(Markdown)
    case latex(start: Token, content: [Self.Latex], end: Token)
    enum Element {
        case single(void: VoidTag)
        case pair(start: StartTag, children: [Syntax], end: EndTag)
        struct VoidTag {
            let openAngle: Token
            let tagName: Text
            let attributes: [Attribute]
            let forwardSlash: Token?
            let closeAngle: Token
        }
        struct StartTag {
            let openAngle: Token
            let tagName: Text
            let attributes: [Attribute]
            let closeAngle: Token
        }
        struct EndTag {
            let openAngle: Token
            let forwardSlash: Token
            let tagName: Text
            let closeAngle: Token
        }
        struct AttributeItem {
            let openQuote: Token?
            let content: Text
            let closeQuote: Token?
        }
        struct Attribute {
            let key: AttributeItem
            let eq: Token
            let value: AttributeItem
        }
    }
    enum Markdown {
        case header(Header)
        case formatBetween(FormatBetween)
        struct Header {
            let hash: Token
            let content: [Syntax]
        }
        /// Formatted/Emphasized content for the following:
        /// 1. [Bold Text](https://www.markdownguide.org/basic-syntax/#bold)
        /// 2. [Italicized Text](https://www.markdownguide.org/basic-syntax/#italic)
        /// 3. [Highlight Text](https://www.markdownguide.org/extended-syntax/#highlight)
        /// 4. [Strikethrough Text](https://www.markdownguide.org/extended-syntax/#strikethrough)
        /// 5. [Subscripts](https://www.markdownguide.org/extended-syntax/#subscript)
        /// 6. [Superscripts](https://www.markdownguide.org/extended-syntax/#superscript)
        struct FormatBetween {
            let open: Token
            let content: [Syntax]
            let close: Token
        }
    }
    enum Latex {
        case plainText(Text)
        case cmd(Cmd)
        case environment(Environment)
        case enclosed(Enclosed)
        struct Cmd {
            let slash: Token
            let ident: Parser.Text
            let arguments: [Enclosed]
        }
        struct Enclosed {
            let open: Token
            let content: [Latex]
            let close: Token
        }
        struct Environment {
            let begin: Begin
            let content: [Latex]
            let end: End
            struct Begin {
                let slash: Token
                let begin: Token
                let open: Token
                let name: Token
                let close: Token
                let arguments: [Enclosed]
            }
            struct End {
                let slash: Token
                let end: Token
                let open: Token
                let name: Token
                let close: Token
            }
        }
    }
}

extension Syntax.Element {
    var tag: Substring {
        switch self {
        case .single(let void):
            return void.tagName.subsequence
        case .pair(let start, _, let end):
            assert(start.tagName.subsequence == end.tagName.subsequence)
            return start.tagName.subsequence
        }
    }
}
extension Syntax.Latex.Environment {
    var name: Substring {
        assert(self.begin.name.subsequence == self.end.name.subsequence)
        return self.begin.name.subsequence
    }
}
