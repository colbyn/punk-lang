//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/18/23.
//

import Foundation


public enum PrettyTree {
    case empty
    case value(String)
    case branch(Branch)
    case fragment([PrettyTree])
    public struct Branch {
        public let name: String
        public let children: [PrettyTree]
    }
    public struct KeyValue {
        public let name: String
        public let value: PrettyTree
    }
}

public protocol ToPrettyTree {
    var prettyTree: PrettyTree {get}
}

extension Array: ToPrettyTree where Element: ToPrettyTree {
    public var prettyTree: PrettyTree {
        if self.isEmpty {
            return PrettyTree("Array([])")
        } else {
            return PrettyTree(name: "Array", children: self.map({$0.prettyTree}))
        }
    }
}

extension PrettyTree {
    public init<Element>(fragment elements: [Element]) where Element: ToPrettyTree {
        self = .fragment(elements.map({$0.prettyTree}))
    }
    public init(name: String, children: [PrettyTree]) {
        self = .branch(.init(name: name, children: children))
    }
    public init(_ value: String) {
        self = .value(value)
    }
    public init(string: String) {
        self = .value(string.debugDescription.truncate(limit: 20))
    }
    public func print() {
        Swift.print(format())
    }
    public func format() -> String {
        self.format(fmt: .init(columns: [])) ?? ""
    }
    internal func format(fmt: Formatter) -> String? {
        switch self {
        case .empty: return ""
        case .value(let string):
            return fmt.leaf(value: string)
        case .branch(let branch):
            let head = fmt.leaf(value: branch.name)
            let children = branch.children
                .enumerated()
                .compactMap { ix, child in
                    let isFirst = ix == 0
                    let isLast = ix + 1 == branch.children.count
                    let isSingle = branch.children.count == 1
                    let fmt = fmt.clearAll()
                    if isSingle {
                        return child.format(fmt: fmt.singleIndent())
                    }
                    if isFirst {
                        return child.format(fmt: fmt.firstIndent())
                    }
                    if isLast {
                        return child.format(fmt: fmt.lastIndent())
                    }
                    return child.format(fmt: fmt.middleIndent())
                }
                .joined()
            return "\(head)\(children)"
        case .fragment(let array):
            if array.isEmpty {
                return ""
            }
            return array
                .enumerated()
                .compactMap { ix, child in
                    let isFirst = ix == 0
                    let isLast = ix + 1 == array.count
                    let fmt = fmt.clearAll()
                    if isFirst && isLast {
                        return child.format(fmt: fmt.singleFragment())
                    }
                    if isFirst {
                        return child.format(fmt: fmt.firstFragment())
                    }
                    if isLast {
                        return child.format(fmt: fmt.lastFragment())
                    }
                    return child.format(fmt: fmt.middleFragment())
                }
                .joined()
        }
    }
}

struct Formatter {
    let columns: [String]
    func leaf(value: String) -> String {
        let columns = self.columns.joined(separator: "    ")
        let sep = columns.isEmpty ? "" : "╼\(THIN_SPACE)"
        return "\(columns)\(sep)\(value)\n"
    }
    func singleIndent() -> Formatter {
        Formatter(columns: columns.with(append: "╰"))
    }
    func clearAll() -> Formatter {
        let columns = columns.map { sym in
            switch sym {
            case "╰", "•":
                return " "
            case "├":
                return "│"
            case "╭":
                return "│"
            default:
                return sym
            }
        }
        return Formatter(columns: columns)
    }
    func firstIndent() -> Formatter {
        Formatter(columns: columns.with(append: "├"))
    }
    func middleIndent() -> Formatter {
        return Formatter(columns: columns.with(append: "├"))
    }
    func lastIndent() -> Formatter {
        return Formatter(columns: columns.with(append: "╰"))
    }
    func firstFragment() -> Formatter {
        Formatter(columns: columns.with(append: "╭"))
    }
    func middleFragment() -> Formatter {
        return Formatter(columns: columns.with(append: "├"))
    }
    func lastFragment() -> Formatter {
        return Formatter(columns: columns.with(append: "╰"))
    }
    func singleFragment() -> Formatter {
        return Formatter(columns: columns.with(append: "•"))
    }
}

// NARROW NO-BREAK SPACE
// Unicode: U+202F, UTF-8: E2 80 AF
fileprivate let NARROW_NO_BREAK_SPACE: String = "\u{202F}";
//MEDIUM MATHEMATICAL SPACE
//Unicode: U+205F, UTF-8: E2 81 9F
fileprivate let MEDIUM_MATHEMATICAL_SPACE: String = "\u{205F}";
//HAIR SPACE
//Unicode: U+200A, UTF-8: E2 80 8A
fileprivate let HAIR_SPACE: String = "\u{200A}";
//THIN SPACE
//Unicode: U+2009, UTF-8: E2 80 89
fileprivate let THIN_SPACE: String = "\u{2009}";
//PUNCTUATION SPACE
//Unicode: U+2008, UTF-8: E2 80 88
fileprivate let PUNCTUATION_SPACE: String = "\u{2008}";
//FIGURE SPACE
//Unicode: U+2007, UTF-8: E2 80 87
fileprivate let FIGURE_SPACE: String = "\u{2007}";
//
//NO-BREAK SPACE
//Unicode: U+00A0, UTF-8: C2 A0
fileprivate let NO_BREAK_SPACE: String = "\u{00A0}";
//EN SPACE
//Unicode: U+2002, UTF-8: E2 80 82
fileprivate let EN_SPACE: String = "\u{2002}";
//EM SPACE
//Unicode: U+2003, UTF-8: E2 80 83
fileprivate let EM_SPACE: String = "\u{2003}";
//THREE-PER-EM SPACE
//Unicode: U+2004, UTF-8: E2 80 84
fileprivate let THREE_PER_EM_SPACE: String = "\u{2004}";
//FOUR-PER-EM SPACE
//Unicode: U+2005, UTF-8: E2 80 85
fileprivate let FOUR_PER_EM_SPACE: String = "\u{2005}";
//SIX-PER-EM SPACE
//Unicode: U+2006, UTF-8: E2 80 86
fileprivate let SIX_PER_EM_SPACE: String = "\u{2006}";

extension PrettyTree {
    public func defragment() -> [PrettyTree] {
        switch self {
        case .empty: return [.empty]
        case .value(let string): return [.value(string)]
        case .branch(let branch):
            let children = branch.children.flatMap({$0.defragment()})
            return [.branch(PrettyTree.Branch(name: branch.name, children: children))]
        case .fragment(let array):
            return array
        }
    }
    public static func refragment(list: [PrettyTree]) -> PrettyTree {
        var list = list
        if list.isEmpty {
            return PrettyTree.empty
        }
        let first = list.removeFirst()
        if list.isEmpty {
            return first
        }
        return PrettyTree.fragment([first].with(tail: list))
    }
}
extension PrettyTree.Branch {
    public func defragment() -> PrettyTree.Branch {
        let children = self.children.flatMap({$0.defragment()})
        return PrettyTree.Branch(name: name, children: children)
    }
}
