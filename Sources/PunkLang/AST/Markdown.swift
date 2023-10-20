//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

indirect enum Markdown {
    case plainText(Parser.Text)
    case header(Header)
    case link(Link)
    case formatted(Formatted)
    case inlineCode(InlineCode)
    case codeBlock(CodeBlock)
    case inlineMath(InlineMath)
    case mathBlock(MathBlock)
    case blockquote(Blockquote)
    case horizontalRule(HorizontalRule)
    case html(Html)
}

extension Markdown {
    struct Header {
        let hash: Parser.Text
        let content: [Markdown]
    }
    enum Link {
        case anchor(Anchor)
        struct Anchor {
            let openSquareBracket: Parser.Text
            let name: Parser.Text
            let closeSquareBracket: Parser.Text
            let openParen: Parser.Text
            let url: Parser.Text
            let closeParen: Parser.Text
        }
    }
    struct Image {}
    struct List {
        
    }
    struct ListItem {
        
    }
    /// Formatted/Emphasized content for the following:
    /// 1. [Bold Text](https://www.markdownguide.org/basic-syntax/#bold)
    /// 2. [Italicized Text](https://www.markdownguide.org/basic-syntax/#italic) Text
    /// 3. [Highlight Text](https://www.markdownguide.org/extended-syntax/#highlight)
    /// 4. [Strikethrough Text](https://www.markdownguide.org/extended-syntax/#strikethrough)
    /// 5. [Subscripts](https://www.markdownguide.org/extended-syntax/#subscript)
    /// 6. [Superscripts](https://www.markdownguide.org/extended-syntax/#superscript)
    struct Formatted {
        let open: Parser.Text
        let content: [Markdown]
        let close: Parser.Text
    }
    struct InlineCode {
        let open: Parser.Text
        let content: Parser.Text
        let close: Parser.Text
    }
    struct CodeBlock {
        let open: Parser.Text
        let language: Parser.Text?
        let content: Parser.Text
        let close: Parser.Text
    }
    struct InlineMath {
        let open: Parser.Text
        let content: [Latex]
        let close: Parser.Text
    }
    struct MathBlock {
        let open: Parser.Text
        let content: [Latex]
        let close: Parser.Text
    }
    struct Blockquote {
        let open: Parser.Text
        let content: [Markdown]
    }
    /// [Horizontal Rules](https://www.markdownguide.org/basic-syntax/#horizontal-rules)
    struct HorizontalRule {
        let token: Parser.Text
    }
}


// MARK: - DEBUGGING -
extension Markdown: ToDebugTree {
    var debugTree: DebugTree {
        switch self {
        case .plainText(let text):
            return text.debugTree
        case .header(let header):
            return header.debugTree
        case .link(let link):
            return link.debugTree
        case .formatted(let formatted):
            return formatted.debugTree
        case .inlineCode(let inlineCode):
            return inlineCode.debugTree
        case .codeBlock(let codeBlock):
            return codeBlock.debugTree
        case .inlineMath(let inlineMath):
            return inlineMath.debugTree
        case .mathBlock(let mathBlock):
            return mathBlock.debugTree
        case .blockquote(let blockquote):
            return blockquote.debugTree
        case .horizontalRule(let horizontalRule):
            return horizontalRule.debugTree
        case .html(let html):
            return html.debugTree
        }
    }
}

extension Markdown.Header: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Header", children: [
            DebugTree(label: "hash", children: [hash.debugTree]),
            DebugTree(label: "content", children: content.map{$0.debugTree}),
        ])
    }
}
extension Markdown.Link: ToDebugTree {
    var debugTree: DebugTree {
        switch self {
        case .anchor(let anchor):
            return anchor.debugTree
        }
    }
}
extension Markdown.Link.Anchor: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Anchor", children: [
            DebugTree(label: "openSquareBracket", children: [openSquareBracket.debugTree]),
            DebugTree(label: "name", children: [name.debugTree]),
            DebugTree(label: "closeSquareBracket", children: [closeSquareBracket.debugTree]),
            DebugTree(label: "openParen", children: [openParen.debugTree]),
            DebugTree(label: "url", children: [url.debugTree]),
            DebugTree(label: "closeParen", children: [closeParen.debugTree]),
        ])
    }
}
extension Markdown.Formatted: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Formatted", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            DebugTree(label: "content", children: content.map{$0.debugTree}),
            DebugTree(label: "close", children: [close.debugTree]),
        ])
    }
}
extension Markdown.InlineCode: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Formatted", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            DebugTree(label: "content", children: [content.debugTree]),
            DebugTree(label: "close", children: [close.debugTree]),
        ])
    }
}
extension Markdown.CodeBlock: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Formatted", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            language
                .map {
                    DebugTree(label: "language", children: [$0.debugTree])
                }
                .unwrap(or: DebugTree.empty),
            DebugTree(label: "content", children: [content.debugTree]),
            DebugTree(label: "close", children: [close.debugTree]),
        ])
    }
}
extension Markdown.InlineMath: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Formatted", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            DebugTree(label: "content", children: content.map{$0.debugTree}),
            DebugTree(label: "close", children: [close.debugTree]),
        ])
    }
}
extension Markdown.MathBlock: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Formatted", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            DebugTree(label: "content", children: content.map{$0.debugTree}),
            DebugTree(label: "close", children: [close.debugTree]),
        ])
    }
}
extension Markdown.Blockquote: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Blockquote", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            DebugTree(label: "content", children: content.map{$0.debugTree}),
        ])
    }
}
extension Markdown.HorizontalRule: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "HorizontalRule", children: [
            DebugTree(label: "token", children: [token.debugTree]),
        ])
    }
}
