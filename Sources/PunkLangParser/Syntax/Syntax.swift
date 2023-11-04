import Foundation
import PrettyTree

/// Main Public Parse Tree (AST)
enum Syntax {
    case string(Parser.StringToken)
    case cmd(Cmd)
    case enclosure(Enclosure)
    case invalid(Invalid)
    case fragment([Syntax])
    struct Cmd {
        let ident: Parser.StringToken
        var arguments: [Enclosure]
    }
    struct Enclosure {
        let open: Parser.CharToken
        let body: [Syntax]
        let close: Parser.CharToken
    }
    struct Unclosed {
        let open: Parser.CharToken
        let body: [Syntax]
    }
    enum Invalid {
        case unclosedBlock(Unclosed)
        case closeToken(Parser.CharToken)
    }
}


// MARK: - DEBUG -
extension Syntax: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .string(let stringToken):
            return PrettyTree(".string(\(stringToken.value.debugDescription))")
        case .cmd(let cmd):
            return cmd.prettyTree
        case .enclosure(let enclosure):
            return enclosure.prettyTree
        case .invalid(let invalid):
            return invalid.prettyTree
        case .fragment(let array):
            return PrettyTree.fragment(array.map({$0.prettyTree}))
        }
    }
}
extension Syntax.Cmd: ToPrettyTree {
    var prettyTree: PrettyTree {
        PrettyTree(name: "Cmd(\(self.ident.value.debugDescription))", children: self.arguments.map({$0.prettyTree}))
    }
}
extension Syntax.Enclosure: ToPrettyTree {
    var prettyTree: PrettyTree {
        return PrettyTree(name: "Enclosure", children: self.body.map({$0.prettyTree}))
    }
}
extension Syntax.Unclosed: ToPrettyTree {
    var prettyTree: PrettyTree {
        return PrettyTree(name: "Syntax.Unclosed", children: self.body.map({$0.prettyTree}))
    }
}
extension Syntax.Invalid: ToPrettyTree {
    var prettyTree: PrettyTree {
        switch self {
        case .unclosedBlock(let unclosed):
            return PrettyTree(name: "Syntax.Invalid.unclosedBlock", children: unclosed.body.map({$0.prettyTree}))
        case .closeToken(let charToken):
            return PrettyTree("Syntax.Invalid.closeToken(\(charToken.value.debugDescription))")
        }
    }
}
