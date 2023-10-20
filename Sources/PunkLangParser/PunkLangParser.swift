//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation
import PrettyTree

fileprivate let sourceCode: String = """
<layout>
    <note>
        # Hello World!
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tristique, nisi
        et imperdiet commodo, lectus urna ultricies sapien, non facilisis eros mauris.
    </note>
    <note>
        # Hello World!
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tristique, nisi
        et imperdiet commodo, lectus urna ultricies sapien, non facilisis eros mauris.
    </note>
</layout>
"""

fileprivate func dev() {
    let parser = Syntax.parser(environment: .default)
    let output = Parser.execute(parser: parser, source: sourceCode)
    print("DONE")
    if let value = output.value {
        print("Success")
        value.prettyTree.print()
    } else {
        print("Failed to parse source code")
    }
    print("UNPARSED")
    print(output.stream.subsequence.debugDescription)
//    let prettyTree1 = PrettyTree(name: "Alpha", children: [
//        .init(name: "Section 1", children: [
//            .init("One"),
//            .init("Two"),
//            .init("Three"),
//        ]),
//        .init(name: "Section 2", children: [
//            .init("One"),
//            .init("Two"),
//            .init("Three"),
//        ]),
//        .init(name: "Section 3", children: [
//            .init("One"),
//            .init("Two"),
//            .init("Three"),
//        ]),
//        .init(name: "Section 4", children: [
//            .init(name: "Alpha", children: [
//                .init(name: "Beta", children: [
//                    .init(name: "Gamma", children: [
//                        .init("Delta")
//                    ])
//                ])
//            ]),
//            .init(name: "Alpha", children: [
//                .init(name: "Beta", children: [
//                    .init(name: "Gamma", children: [
//                        .init("Delta")
//                    ])
//                ])
//            ]),
//        ]),
//        .init(name: "Section 5", children: [
//            .init(name: "Alpha", children: [
//                .init(name: "Beta", children: [
//                    .init(name: "Gamma", children: [
//                        .init("Delta")
//                    ])
//                ])
//            ]),
//            .init(name: "Alpha", children: [
//                .init(name: "Beta", children: [
//                    .init(name: "Gamma", children: [
//                        .init("Delta")
//                    ])
//                ])
//            ]),
//        ]),
//    ])
//    prettyTree1.print()
//    let parser = Syntax.Element.StartTag.parser
//    let output = Parser.execute(parser: parser, source: sourceCode)
//    if let value = output.value {
//        print("Parsed", value)
//    }
//    if let (left, right) = s1.splitAt(whereTrue: {$0.isWhitespace}) {
//        print("left", left.subsequence.debugDescription)
//        print("right", right.subsequence.debugDescription)
//    }
    
    
//    var (begin, text) = Parser.Tex(string: sourceCode).splitPrefix(string: "<")!
//    var counter = 0
//    while let (current, next) = text.advance(by: 1) {
////        let value = current.subsequence
//        let match = sourceCode[current.span.start.localIndex...sourceCode.index(before: current.span.end.localIndex)]
//        print("current", current.subsequence.debugDescription, " <=> ", next.subsequence.debugDescription)
////        if counter > 10 { break }
//        counter += 1
//        text = next
//    }
//    print("TEXT", text)
//    var subtext = sourceText
//    var counter = 0
//    while let newSubtext = subtext.advance() {
//        print("subtext", newSubtext.subsequence.debugDescription)
//        counter += 1
//        if counter > 10 {
//            break
//        }
//        subtext = newSubtext
//    }
}

public struct PunkLangParser {
    public static func main() {
        print("Running PunkLangParser")
        dev()
    }
}
