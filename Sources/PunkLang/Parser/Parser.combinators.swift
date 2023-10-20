//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

extension Parser {
    static func consume<A, B>(parser: @autoclosure @escaping () -> Monad<A>, until: @autoclosure @escaping () -> Monad<B>) -> Monad<([A], B)> {
        Monad<([A], B)> { s1 in
            var xs: [A] = []
            var stream = s1
        loop: while true {
            switch until().binder(stream) {
            case .err:
                switch parser().binder(stream) {
                case .err(let es, let next):
                    return .err(es.with(append: .noMatch), next)
                case.ok(let a, let next):
                    xs.append(a)
                    stream = next
                    continue loop
                }
            case.ok(let b, let s2):
                return .ok((xs, b), s2)
            }
        }
        }
    }
    static func consumeRestOfLine<A>(parser: @autoclosure @escaping () -> Monad<A>) -> Monad<[A]> {
        Parser.consume(parser: parser(), until: TextMonad.newline)
            .map({$0.0})
    }
    static func consumeIndentedBlock<A, B>(
        header: @autoclosure @escaping () -> Monad<A>,
        indented: @autoclosure @escaping () -> Monad<B>
    ) -> Monad<(A, [B])> {
        return Monad<(A, [B])> { s1 in
            let startColumn = s1.column
            let startLine = s1.line
            let leadingWhitespace = TextMonad.anyWhitespace
            let indented: Monad<B> = Monad<B> { next1 in
                switch leadingWhitespace.binder(next1) {
                case .err(let e, let next2): return .err(e, next2)
                case .ok(_, let next2):
                    let check1 = next2.line > startLine
                    let check2 = next2.column > startColumn
                    let isValid = check1 && check2
                    if isValid {
                        switch indented().binder(next2) {
                        case .err(let e, let next3): return .err(e, next3)
                        case.ok(let x, let next3): return .ok(x, next3)
                        }
                    }
                    return .err([.noMatch], next1)
                }
            }
            switch header().binder(s1) {
            case .err(let es, _):
                return .err(es.with(append: .noMatch), s1)
            case.ok(let a, let s2):
                switch Parser.some(indented).binder(s2) {
                case .err(let err, let s3):
                    return .err(err, s3)
                case.ok(let bs, let s3):
                    return .ok((a, bs), s3)
                }
            }
        }
    }
    static func optional<A>(_ parser: @autoclosure @escaping () -> Monad<A>) -> Monad<A?> {
        Monad<A?> { s1 in
            switch parser().binder(s1) {
            case .err: return .ok(nil, s1)
            case.ok(let a, let s2): return .ok(a, s2)
            }
        }
    }
    static private func many<A>(f: @autoclosure @escaping () -> Monad<A>, failedIfEmpty: Bool) -> Monad<[A]> {
        Monad<[A]> { s1 in
            var xs: [A] = []
            var copy = s1
        loop: repeat {
            switch f().binder(copy) {
            case .ok(let a, let new):
                copy = new
                xs.append(a)
                continue loop
            case .err:
                break loop
            }
        } while !copy.view.isEmpty
            if xs.isEmpty && failedIfEmpty {
                return .err([.empty], copy)
            }
            return .ok(xs, copy)
        }
    }
    static func many<A>(_ parser: @autoclosure @escaping () -> Monad<A>) -> Monad<[A]> {
        Self.many(f: parser(), failedIfEmpty: false)
    }
    static func some<A>(_ parser: @autoclosure @escaping () -> Monad<A>) -> Monad<[A]> {
        Self.many(f: parser(), failedIfEmpty: true)
    }
    static func run<A>(parser: Monad<A>, source: String) -> Output<A> {
        let stream = Stream(from: source)
        return parser.binder(stream)
    }
    static func oneOf<A>(parsers: [() -> Monad<A>]) -> Monad<A> {
        Monad<A> { s1 in
        loop: for parser in parsers {
            switch parser().binder(s1) {
            case .ok(let a, let s2): return .ok(a, s2)
            case .err: continue loop
            }
        }
            return .err([.noMatch], s1)
        }
    }
    static func oneOf<A, B>(parsers: [() -> Monad<A>], ignoring: @autoclosure @escaping () -> Monad<B>) -> Monad<A> {
        Monad<A> { s1 in
        loop: for parser in parsers {
            switch (Parser.optional(ignoring()).keepRight(parser())).binder(s1) {
            case .ok(let a, let s2): return .ok(a, s2)
            case .err: continue loop
            }
        }
            return .err([.noMatch], s1)
        }
    }
    static func pair<A, B>(
        left: @autoclosure @escaping () -> Monad<A>,
        right: @autoclosure @escaping () -> Monad<B>
    ) -> Monad<(A, B)> {
        left().and(right())
    }
    static func between<Left, Center, Right>(
        left: @autoclosure @escaping () -> Monad<Left>,
        center: @autoclosure @escaping () -> Monad<Center>,
        right: @autoclosure @escaping () -> Monad<Right>
    ) -> Monad<(Left, Center, Right)> {
        left().and2(center(), right())
    }
    static func either<A, B>(
        left: @autoclosure @escaping () -> Monad<A>,
        right: @autoclosure @escaping () -> Monad<B>
    ) -> Monad<Either<A, B>> {
        Monad<Either<A, B>> { s1 in
            switch left().binder(s1) {
            case .ok(let a, let s2):
                return .ok(Either.left(a), s2)
            case .err(_, _):
                switch right().binder(s1) {
                case .ok(let b, let s2):
                    return .ok(Either.right(b), s2)
                case .err(_, _):
                    return .err([.noMatch], s1)
                }
            }
        }
    }
    static func betweenAnyQuote<A>(_  parser: @escaping (Character) -> Monad<A>) -> Monad<(Parser.Text, A, Parser.Text)> {
        let parser1 = Parser.between(left: TextMonad.match(prefix: "\""), center: parser("\""), right: TextMonad.match(prefix: "\""))
        let parser2 = Parser.between(left: TextMonad.match(prefix: "'"), center: parser("'"), right: TextMonad.match(prefix: "'"))
        return Parser.either(left: parser1, right: parser2).map { res in
            switch res {
            case .left(let value): return value
            case .right(let value): return value
            }
        }
    }
}

