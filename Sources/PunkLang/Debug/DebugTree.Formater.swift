//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

fileprivate let DOWN_AND_RIGHT: String = "├"
fileprivate let DOWN: String = "│"
fileprivate let TURN_RIGHT: String = "╰"
fileprivate let RIGHT: String = "─"
fileprivate let EMPTY: String = " "

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

extension DebugTree {
    typealias AtColumnEnd = Bool
    typealias AtChildEnd = Bool
    struct Formater {
        var columns: [AtColumnEnd] = []
        var isLast: AtChildEnd = false
        var isLastMostFragment: Bool = false
        var isMiddleFragment: Bool = false
        var isHead: Bool = false
    }
}

extension DebugTree.Formater {
    func indent() -> Self {
        var copy = self
        copy.columns.append(self.isLast)
        return copy
    }
    func beginAligned() -> Self {
        var copy = self
        copy.isLast = false
        copy.isLastMostFragment = false
        return copy
    }
    func markLastElement() -> Self {
        var copy = self
        copy.isLast = true
        return copy
    }
    func markLastMostFragment() -> Self {
        var copy = self
        copy.isLastMostFragment = true
        copy.isHead = false
        return copy
    }
    func markMiddleFragment() -> Self {
        var copy = self
        copy.isMiddleFragment = true
        copy.isHead = false
        return copy
    }
    func markHead() -> Self {
        var copy = self
        copy.isHead = true
        return copy
    }
}

extension DebugTree.Formater {
    func leading() -> String {
        let begin = {
            let endChar = "╼"
            if self.columns.isEmpty {
                if self.isHead {
                    return "╭\(endChar)"
                } else if self.isLast && self.isLastMostFragment {
                    return "\(TURN_RIGHT)\(endChar)"
                } else {
                    return "\(DOWN_AND_RIGHT)\(endChar)"
                }
            } else {
                if self.isMiddleFragment {
                    return "\(DOWN)"
                } else {
                    return " "
                }
            }
        }()
        func for_each_level(_ ix: Int, _ at_end: DebugTree.AtChildEnd, _ column_end: DebugTree.AtColumnEnd) -> String {
            let indent = "\(EM_SPACE)\(EM_SPACE)\(EM_SPACE)";
            let terminal = {
                let end_char = "╼";
                if self.isLast {
                    return "\(TURN_RIGHT)\(end_char)"
                } else {
                    return "\(DOWN_AND_RIGHT)\(end_char)"
                }
            }()
            let intermediate = {
                if column_end {
                    return ""
                } else {
                    return DOWN
                }
            }()
            let sep = {
                if at_end {
                    return terminal
                } else {
                    return intermediate
                }
            }()
            let result = "\(indent)\(sep)";
            return result
        }
        let columns_count = self.columns.count
        let results = self.columns
            .enumerated()
            .map({ ix, columnEnd in
                let at_end = ix + 1 == columns_count;
                return for_each_level(ix, at_end, columnEnd)
            })
            .joined()
        let result = "\(begin)\(results)"
        return result
    }
    public func leaf(value: String) -> String {
        let leading = self.leading()
        return "\(leading)\(HAIR_SPACE)\(value)"
    }
}

extension DebugTree {
    func format(with f: Self.Formater) -> String? {
        switch self {
        case .empty: return nil
        case .label(let label):
            return f.leaf(value: label)
        case .branch(let x):
            let header = f.leaf(value: x.label)
            let children_len = x.children.count
            let empty_children = x.children.isEmpty
            let fx = f.beginAligned()
            let children = x.children
                .enumerated()
                .compactMap({ (ix, x) in
                    let is_last = ix + 1 == children_len;
                    if is_last {
                        return x.format(with: fx.markLastElement().indent())
                    } else {
                        return x.format(with: fx.indent())
                    }
                })
                .joined(separator: "\n")
            if empty_children {
                return header
            } else {
                return [header, children].joined(separator: "\n")
            }
        case .fragment(let children):
            let children_len = children.count
            let empty_children = children.isEmpty
            let children = children
                .enumerated()
                .compactMap({ (ix, x) in
                    let is_last = ix + 1 == children_len;
                    let is_first = ix == 0;
                    if is_last {
                        if is_first {
                            return x.format(with: f.markLastElement().markLastMostFragment().markHead())
                        } else {
                            return x.format(with: f.markLastElement().markLastMostFragment())
                        }
                    } else {
                        if is_first {
                            return x.format(with: f.markMiddleFragment().markHead())
                        } else {
                            return x.format(with: f.markMiddleFragment())
                        }
                    }
                })
                .joined(separator: "\n")
            if empty_children {
                return .none
            } else {
                return children
            }
        }
    }
}
