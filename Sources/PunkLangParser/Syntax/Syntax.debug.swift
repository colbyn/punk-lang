//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/18/23.
//

import Foundation
import PrettyTree

// MARK: - PARSER -
extension Parser.Text: ToPrettyTree {
    public var prettyTree: PrettyTree {
        PrettyTree(self.subsequence.debugDescription)
    }
}

// MARK: - SYNAX -
extension Syntax: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .plainText(let x): return PrettyTree("\(x.subsequence.debugDescription.truncate(limit: 50)) ﹕ PlainText")
        case .element(let x): return x.prettyTree
        case .markdown(let x): return x.prettyTree
        case .latex(let start, let content, let end):
            let contents = [
                [PrettyTree("\(start.subsequence)")],
                content.map({$0.prettyTree}),
                [PrettyTree("\(end.subsequence)")],
            ]
            return .fragment(contents.flatMap({$0}).flatMap({$0.defragment()}))
        }
    }
}

extension Syntax.Element.StartTag: ToPrettyTree {
    var prettyTree: PrettyTree {
        let attributes = attributes.isEmpty ? "" : " \(attributes.map{$0.asString}.joined(separator: " "))"
        return PrettyTree("<\(tagName.subsequence)\(attributes)> ﹕ StartTag")
    }
}
extension Syntax.Element.EndTag: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree("</\(tagName.subsequence)> ﹕ EndTag")
    }
}
extension Syntax.Element.VoidTag: ToPrettyTree {
    var prettyTree: PrettyTree {
        let attributes = attributes.isEmpty ? "" : " \(attributes.map{$0.asString}.joined(separator: " "))"
        return PrettyTree("<\(tagName.subsequence)\(attributes)/> ﹕ VoidTag")
    }
}
extension Syntax.Element.AttributeItem: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree(self.content.subsequence.debugDescription)
    }
}
extension Syntax.Element.Attribute: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree(name: "Attribute", children: [
            self.key.prettyTree,
            self.eq.prettyTree,
            self.value.prettyTree,
        ])
    }
    var asString: String {
        "\(self.key.content.subsequence.debugDescription)=\(self.value.content.subsequence.debugDescription)"
    }
}
extension Syntax.Element: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .single(void: let x): return x.prettyTree
        case .pair(start: let start, children: let children, end: let end):
            let values = [
                [start.prettyTree],
                children.map {$0.prettyTree},
                [end.prettyTree],
            ]
            return PrettyTree.fragment(values.flatMap({$0}))
        }
    }
}
extension Syntax.Markdown.FormatBetween: ToPrettyTree {
    var prettyTree: PrettyTree {
        let node = PrettyTree(name: "FormatBetween", children: [
            self.open.prettyTree,
            PrettyTree.fragment(self.content.map {$0.prettyTree}),
            self.close.prettyTree,
        ])
//        return PrettyTree.refragment(list: node.defragment())
        return node
    }
}
extension Syntax.Markdown.Header: ToPrettyTree {
    var prettyTree: PrettyTree {
        let node = PrettyTree(name: "Header", children: [
            self.hash.prettyTree,
            PrettyTree.fragment(self.content.map {$0.prettyTree}),
        ])
        return PrettyTree.refragment(list: node.defragment())
    }
}
extension Syntax.Markdown: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .formatBetween(let x): return x.prettyTree
        case .header(let x): return x.prettyTree
        }
    }
}
extension Syntax.Latex.Enclosed: ToPrettyTree {
    var prettyTree: PrettyTree {
        let open = self.open.subsequence
        let close = self.close.subsequence
        return PrettyTree.init(name: "\(open)\(close)", children: self.content.map {$0.prettyTree})
    }
}
extension Syntax.Latex.Cmd: ToPrettyTree {
    var prettyTree: PrettyTree {
        let header = "\\\(ident.subsequence) ﹕ Cmd"
        if self.arguments.isEmpty {
            return PrettyTree(header)
        }
        return PrettyTree(name: header, children: self.arguments.flatMap { $0.prettyTree.defragment() })
    }
}
extension Syntax.Latex.Environment.Begin: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree("\\begin{\(name.subsequence)} ﹕ Begin")
    }
}
extension Syntax.Latex.Environment.End: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree("\\end{\(name.subsequence)} ﹕ End")
    }
}
extension Syntax.Latex.Environment: ToPrettyTree {
    var prettyTree: PrettyTree {
        return PrettyTree.fragment([
            [self.begin.prettyTree],
            self.content.map { $0.prettyTree },
            [self.end.prettyTree]
        ].flatMap({$0}))
    }
}
extension Syntax.Latex: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .plainText(let x): return PrettyTree(x.subsequence.debugDescription)
        case .cmd(let x): return x.prettyTree
        case .environment(let x): return x.prettyTree
        case .enclosed(let x): return x.prettyTree
        }
    }
}
