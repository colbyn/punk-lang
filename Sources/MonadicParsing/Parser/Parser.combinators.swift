//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

extension Parser {
    fileprivate static func manyImpl<A, B>(
        parser: @autoclosure @escaping () -> IO<A>,
        failIfEmpty: Bool,
        until: (() -> IO<B>)?
    ) -> IO<[A]> {
        IO<[A]> { input in
            var xs: [A] = []
            var stream = input
            loop: while true {
                if let until = until {
                    switch until().binder(stream) {
                    case .ok: break loop
                    case .err: ()
                    }
                }
                switch parser().binder(stream) {
                case .err(_):
                    return .ok(value: xs, stream: stream)
                case .ok(let value, let next):
                    xs.append(value)
                    stream = next
                    continue loop
                }
            }
            return .ok(value: xs, stream: stream)
        }
    }
    public static func many<A>(
        _ parser: @autoclosure @escaping () -> IO<A>
    ) -> IO<[A]> {
        manyImpl(parser: parser(), failIfEmpty: false, until: Optional<() -> (Parser.IO<()>)>.none)
    }
    public static func some<A>(_ parser: @autoclosure @escaping () -> IO<A>) -> IO<[A]> {
        manyImpl(parser: parser(), failIfEmpty: true, until: Optional<() -> Parser.IO<()>>.none)
    }
    public static func some<A, B>(
        _ parser: @autoclosure @escaping () -> IO<A>,
        until: @autoclosure @escaping () -> IO<B>
    ) -> IO<[A]> {
        manyImpl(parser: parser(), failIfEmpty: true, until: until)
    }
    public static func many<A, B>(
        _ parser: @autoclosure @escaping () -> IO<A>,
        until: @autoclosure @escaping () -> IO<B>
    ) -> IO<[A]> {
        manyImpl(parser: parser(), failIfEmpty: false, until: until)
    }
    public static func `try`<A>(_ parser: @autoclosure @escaping () -> IO<A>) -> IO<A?> {
        IO<A?> { input in
            switch parser().binder(input) {
            case .ok(let value, let stream): return .ok(value: value, stream: stream)
            case .err(let stream): return .ok(value: nil, stream: stream)
            }
        }
    }
    public static func either<A, B>(
        left: @autoclosure @escaping () -> IO<A>,
        right: @autoclosure @escaping () -> IO<B>
    ) -> IO<Either<A, B>> {
        IO<Either<A, B>> { input in
            switch left().binder(input) {
            case .ok(let value, let stream): return .ok(value: .left(value), stream: stream)
            case .err(_):
                switch right().binder(input) {
                case .ok(let value, let stream): return .ok(value: .right(value), stream: stream)
                case .err(_): return Parser.State.err(stream: input)
                }
            }
        }
    }
    public static func options<A>(_ parsers: () -> IO<A>...) -> IO<A> {
        IO<A> { input in
        loop: for parser in parsers {
                switch parser().binder(input) {
                case .err(_): continue loop
                case .ok(let value, let stream): return .ok(value: value, stream: stream)
                }
            }
            return .err(stream: input)
        }
    }
    public static func options<A>(_ parsers: IO<A>..., debug: Optional<String> = .none) -> IO<A> {
        IO<A> { input in
        loop: for parser in Array(parsers) {
            switch parser.binder(input) {
            case .ok(let value, let stream): return .ok(value: value, stream: stream)
            case .err(_): continue loop
            }
        }
            if let debug = debug {
                print("NO MATCH", debug)
                return parsers[1].binder(input)
            }
            return .err(stream: input)
        }
    }
    public static var space: Parser.TextIO {
        Parser.try(Parser.TextIO.collect {$0.isWhitespace && !$0.isNewline}).map { $0.unwrap(or: Text(string: "")) }
    }
    public static var anyWhitespace: Parser.TextIO {
        Parser.TextIO.collect {$0.isWhitespace}
    }
    public static func allowSpace<A>(_ parser: @autoclosure @escaping () -> IO<A>) -> IO<A> {
        let space = Parser.try(Parser.space)
        return space.next(parser()).andTry(space).map {$0.0}
    }
    public static func allowAnyWhiteSpace<A>(_ parser: @autoclosure @escaping () -> IO<A>) -> IO<A> {
        let space = Parser.try(Parser.anyWhitespace)
        return space.next(parser()).andTry(space).map {$0.0}
    }
    public static func allowTrailingSpace<A>(_ parser: @autoclosure @escaping () -> IO<A>) -> IO<A> {
        let space = Parser.try(Parser.space)
        return parser().andTry(space).map {$0.0}
    }
    public static func allowLeadingSpace<A>(_ parser: @autoclosure @escaping () -> IO<A>) -> IO<A> {
        let space = Parser.try(Parser.space)
        return space.next(parser())
    }
    public static func untilEndOfLine<A>(do parser: @autoclosure @escaping () -> Parser.IO<A>) -> Parser.IO<[A]> {
        Parser.some(parser(), until: Parser.TextIO.token("\n"))
    }
    public static func enclosedBetween<A, B, C>(
        start: @autoclosure @escaping () -> Parser.IO<A>,
        content: @autoclosure @escaping () -> Parser.IO<B>,
        end: @autoclosure @escaping () -> Parser.IO<C>
    ) -> Parser.IO<(A, [B], C)> {
        return start()
            .then { start in
                Parser.many(content(), until: end()).and(end()).map {content, end in (start, content, end)}
            }
    }
}

extension Parser.IO {
    public func allowTrailingSpace() -> Self {
        Parser.allowTrailingSpace(self)
    }
    public func allowLeadingSpace() -> Self {
        Parser.allowLeadingSpace(self)
    }
    public func allowSpace() -> Self {
        Parser.allowSpace(self)
    }
    public func allowAnyWhitespace() -> Self {
        Parser.allowAnyWhiteSpace(self)
    }
}

extension Parser.TextIO {
    public static func match(prefix: String) -> Self {
        Self { input in
            guard let (token, rest) = input.splitPrefix(string: prefix) else {
                return .init(value: nil, stream: input)
            }
            return .init(value: token, stream: rest)
        }
    }
    public static func token(_ value: String) -> Self {
        self.match(prefix: value)
    }
    /// Collects all characters while the given predicate is true.
    public static func collect(whileTrue pred: @escaping (Character) -> Bool) -> Self {
        Self { input in
            guard let (token, rest) = input.collect(whileTrue: pred) else {
                return Parser.State.err(stream: input)
            }
            return .init(value: token, stream: rest)
        }
    }
    public static var head: Parser.TextIO {
        Parser.TextIO { input in
            guard let (char, rest) = input.advance(by: 1) else {
                return .err(stream: input)
            }
            return .ok(value: char, stream: rest)
        }
    }
    public static var number: Parser.TextIO {
        Parser.TextIO.collect(whileTrue: {$0.isNumber})
    }
}
