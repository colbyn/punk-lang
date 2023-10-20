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
        }
    }
}

extension Syntax.Element.StartTag: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree("<\(tagName.subsequence)> ﹕ StartTag")
    }
}
extension Syntax.Element.EndTag: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree("</\(tagName.subsequence)> ﹕ EndTag")
    }
}
extension Syntax.Element.VoidTag: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree("<\(tagName.subsequence)/> ﹕ VoidTag")
    }
}
extension Syntax.Element: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .single(void: let x): return x.prettyTree
        case .pair(start: let start, children: let children, end: let end):
            let branch = PrettyTree(name: "\(self.tag) ﹕ Element", children: [
                start.prettyTree,
                PrettyTree.fragment(children.map {$0.prettyTree}),
                end.prettyTree,
            ])
//            return PrettyTree.refragment(list: branch.defragment())
            return branch
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
//        return PrettyTree.refragment(list: node.defragment())
        return node
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
        let enclosed = PrettyTree(name: "Enclosed", children: [
            self.open.prettyTree,
            PrettyTree.fragment(self.content.map {$0.prettyTree}),
            self.close.prettyTree,
        ])
//        return PrettyTree.refragment(list: enclosed.defragment())
        return enclosed
    }
}
extension Syntax.Latex.Cmd: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree(name: "\\\(ident.subsequence) ﹕ Cmd", children: [
            PrettyTree(name: "arguments", children: self.arguments.map { $0.prettyTree })
        ])
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
        let environment = PrettyTree(name: "\\\(name) ﹕ Environment", children: [
            self.begin.prettyTree,
            .fragment(self.content.map { $0.prettyTree }),
            self.end.prettyTree,
        ])
//        return PrettyTree.refragment(list: environment.defragment())
        return environment
    }
}
extension Syntax.Latex: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .cmd(let x): return x.prettyTree
        case .environment(let x): return x.prettyTree
        }
    }
}
