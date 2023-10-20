//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

enum Latex {
    case plainText(Parser.Text)
    case symbol(Parser.Text)
    case cmd(Cmd)
}

extension Latex {
    struct Enclosed {
        let open: Parser.Text
        let content: [Latex]
        let close: Parser.Text
    }
    struct Cmd {
        let backslash: Parser.Text
        let ident: Parser.Text
        let arguments: [Enclosed]
    }
}

// MARK: - DEBUGGING -
extension Latex: ToDebugTree {
    var debugTree: DebugTree {
        switch self {
        case .plainText(let text):
            return text.debugTree
        case .symbol(let symbol):
            return symbol.debugTree
        case .cmd(let cmd):
            return cmd.debugTree
        }
    }
}
extension Latex.Enclosed: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Enclosed", children: [
            DebugTree(label: "open", children: [open.debugTree]),
            DebugTree(label: "content", children: content.map{$0.debugTree}),
            DebugTree(label: "close", children: [close.debugTree]),
        ])
    }
}
extension Latex.Cmd: ToDebugTree {
    var debugTree: DebugTree {
        DebugTree(label: "Cmd", children: [
            DebugTree(label: "backslash", children: [backslash.debugTree]),
            DebugTree(label: "ident", children: [ident.debugTree]),
            DebugTree(label: "arguments", children: arguments.map{$0.debugTree}),
        ])
    }
}
