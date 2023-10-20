//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

indirect enum Html {
    case markdown(Markdown)
    case element(Element)
    enum Element {
        case void(VoidElement)
        case block(BlockElement)
    }
}

extension Html.Element {
    struct InQuotes<Value> {
        let openQuote: Parser.Text
        let value: Value
        let closeQuote: Parser.Text
    }
    struct InQuoteOpt<Value> {
        let openQuote: Parser.Text?
        let value: Value
        let closeQuote: Parser.Text?
    }
    struct Attribute {
        let key: InQuoteOpt<Parser.Text>
        let eq: Parser.Text
        let value: InQuoteOpt<Parser.Text>
    }
    struct VoidElement {
        let openAngle: Parser.Text
        let tagName: Parser.Text
        let attributes: [Attribute]
        let forwardSlash: Parser.Text?
        let closeAngle: Parser.Text
    }
    struct BlockElement {
        let open: Parser.Ann<OpenTag>
        let children: [Html]
        let close: Parser.Ann<CloseTag>
        struct OpenTag {
            let openAngle: Parser.Text
            let tagName: Parser.Text
            let attributes: [Attribute]
            let closeAngle: Parser.Text
        }
        struct CloseTag {
            let openAngle: Parser.Text
            let forwardSlash: Parser.Text
            let tagName: Parser.Text
            let closeAngle: Parser.Text
        }
    }
}

extension Html.Element.BlockElement {
    var tag: String { open.data.tagName.data }
}
extension Html.Element.VoidElement {
    var tag: String { self.tagName.data }
}
extension Html.Element {
    var tag: String {
        switch self {
        case .void(let x): return x.tag
        case .block(let x): return x.tag
        }
    }
}


// MARK: - DEBUGGING -
extension Html: ToDebugTree {
    var debugTree: DebugTree {
        switch self {
        case .markdown(let markdown):
            return markdown.debugTree
        case .element(let element):
            return element.debugTree
        }
    }
}
extension Html.Element: ToDebugTree {
    var debugTree: DebugTree {
        switch self {
        case .void(let voidElement):
            return voidElement.debugTree
        case .block(let blockElement):
            return blockElement.debugTree
        }
    }
}
extension Html.Element.InQuoteOpt: ToDebugTree where Value: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(fragment: [
            self.openQuote.map { $0.debugTree }.unwrap(or: DebugTree.empty),
            self.value.debugTree,
            self.closeQuote.map { $0.debugTree }.unwrap(or: DebugTree.empty),
        ])
    }
}
extension Html.Element.Attribute: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Attribute", children: [
            self.key.debugTree,
            self.eq.debugTree,
            self.value.debugTree,
        ])
    }
}
extension Html.Element.VoidElement: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "VoidElement", children: [
            DebugTree(label: "openAngle", children: [openAngle.debugTree]),
            DebugTree(label: "tagName", children: [tagName.debugTree]),
            DebugTree(label: "attributes", children: [attributes.debugTree]),
            forwardSlash
                .map {x in
                    DebugTree(label: "forwardSlash", children: [x.debugTree])
                }
                .unwrap(or: DebugTree.empty),
            DebugTree(label: "closeAngle", children: [closeAngle.debugTree]),
        ])
    }
}
extension Html.Element.BlockElement.OpenTag: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "OpenTag", children: [
            DebugTree(label: "openAngle", children: [openAngle.debugTree]),
            DebugTree(label: "tagName", children: [tagName.debugTree]),
            DebugTree(label: "attributes", children: attributes.map{$0.debugTree}),
            DebugTree(label: "closeAngle", children: [closeAngle.debugTree]),
        ])
    }
}
extension Html.Element.BlockElement.CloseTag: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "CloseTag", children: [
            DebugTree(label: "openAngle", children: [openAngle.debugTree]),
            DebugTree(label: "forwardSlash", children: [forwardSlash.debugTree]),
            DebugTree(label: "tagName", children: [tagName.debugTree]),
            DebugTree(label: "closeAngle", children: [closeAngle.debugTree]),
        ])
    }
}
extension Html.Element.BlockElement: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "BlockElement", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            DebugTree(label: "children", children: [children.debugTree]),
            DebugTree(label: "close", children: [close.debugTree]),
        ])
    }
}


