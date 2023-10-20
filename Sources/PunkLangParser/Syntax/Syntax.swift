//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/18/23.
//

import Foundation

enum Syntax {
    case plainText(Parser.Text)
    case element(Element)
    case markdown(Markdown)
    enum Element {
        case single(void: VoidTag)
        case pair(start: StartTag, children: [Syntax], end: EndTag)
        struct VoidTag {
            let openAngle: Parser.Text
            let tagName: Parser.Text
            let forwardSlash: Parser.Text?
            let closeAngle: Parser.Text
        }
        struct StartTag {
            let openAngle: Parser.Text
            let tagName: Parser.Text
            let closeAngle: Parser.Text
        }
        struct EndTag {
            let openAngle: Parser.Text
            let forwardSlash: Parser.Text
            let tagName: Parser.Text
            let closeAngle: Parser.Text
        }
    }
    enum Markdown {
        case header(Header)
        case formatBetween(FormatBetween)
        struct Header {
            let hash: Parser.Text
            let content: [Syntax]
        }
        /// Formatted/Emphasized content for the following:
        /// 1. [Bold Text](https://www.markdownguide.org/basic-syntax/#bold)
        /// 2. [Italicized Text](https://www.markdownguide.org/basic-syntax/#italic) Text
        /// 3. [Highlight Text](https://www.markdownguide.org/extended-syntax/#highlight)
        /// 4. [Strikethrough Text](https://www.markdownguide.org/extended-syntax/#strikethrough)
        /// 5. [Subscripts](https://www.markdownguide.org/extended-syntax/#subscript)
        /// 6. [Superscripts](https://www.markdownguide.org/extended-syntax/#superscript)
        struct FormatBetween {
            let open: Parser.Text
            let content: [Syntax]
            let close: Parser.Text
        }
    }
    enum Latex {
        case cmd(Cmd)
        case environment(Environment)
        struct Cmd {
            let slash: Parser.Text
            let ident: Parser.Text
            let arguments: [Enclosed]
        }
        struct Enclosed {
            let open: Parser.Text
            let content: [Latex]
            let close: Parser.Text
        }
        struct Environment {
            let begin: Begin
            let content: [Latex]
            let end: End
            struct Begin {
                let name: Parser.Text
            }
            struct End {
                let name: Parser.Text
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
