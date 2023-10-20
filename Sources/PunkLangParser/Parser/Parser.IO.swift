//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

extension Parser {
    /// The Parser 'IO' Monad.
    public struct IO<A> {
        internal let binder: (Parser.Text) -> Parser.State<A>
    }
    /// Some `Tex` value wrapped in the 'IO' monad.
    public typealias TextIO = IO<Parser.Text>
}



// MARK: - INIT -
extension Parser.IO {
    static func fail() -> Self {
        Self { s in .init(value: nil, stream: s) }
    }
    public static func pure(value: A) -> Self {
        Self { s in .init(value: value, stream: s) }
    }
}

// MARK: - BASIC METHODS -
extension Parser.IO {
    /// Executes the current binder.
    internal func transform<B>(_ f: @escaping (Parser.State<A>) -> Parser.State<B>) -> Parser.IO<B> {
        return Parser.IO<B> { input in
            return f(self.binder(input))
        }
    }
    /// Executes the current binder within the current context.
    internal func bind<B>(_ f: @escaping (A, Parser.Text) -> Parser.State<B>) -> Parser.IO<B> {
        return Parser.IO<B> { input in
            let output = self.binder(input)
            if let a = output.value {
                return f(a, output.stream)
            }
            return .init(value: nil, stream: input)
        }
    }
    /// Maps the wrapped value.
    public func map<B>(_ f: @escaping (A) -> B) -> Parser.IO<B> {
        transform({$0.map(f)})
    }
    /// Chain together muliple parsers.
    public func then<B>(_ f: @escaping (A) -> Parser.IO<B>) -> Parser.IO<B> {
        transform { input in
            if let value = input.value {
                return f(value).binder(input.stream)
            }
            return .init(value: nil, stream: input.stream)
        }
    }
    /// Chain together muliple parsers; forgetting the current value.
    public func next<B>(_ f: @autoclosure @escaping () -> Parser.IO<B>) -> Parser.IO<B> {
        then {_ in f()}
    }
    /// Chain together muliple parsers; forgetting the current value.
    public func nextTry<B>(_ f: @autoclosure @escaping () -> Parser.IO<B>) -> Parser.IO<B> {
        transform { input in
            if input.value.isSome {
                let output = f().binder(input.stream)
                let b = output.value
                return Parser.State(value: b, stream: output.stream)
            }
            return Parser.State(value: nil, stream: input.stream)
        }
    }
    /// Chain together muliple parsers.
    public func and<B>(_ f: @autoclosure @escaping () -> Parser.IO<B>) -> Parser.IO<(A, B)> {
        self.transform { input in
            if let a = input.value {
                return f().binder(input.stream).map {b in (a, b)}
            }
            return Parser.State(value: nil, stream: input.stream)
        }
    }
    /// Chain together muliple parsers.
    public func andTry<B>(_ f: @autoclosure @escaping () -> Parser.IO<B>) -> Parser.IO<(A, B?)> {
        transform { input in
            if let a = input.value {
                let output = f().binder(input.stream)
                let b = output.value
                return Parser.State(value: (a, b), stream: output.stream)
            }
            return Parser.State(value: nil, stream: input.stream)
        }
    }
    /// Fallback to the given parser.
    public func or(_ fallback: @escaping () -> Parser.IO<A>) -> Parser.IO<A> {
        transform { input in
            if input.value.isSome {
                return input
            }
            return fallback().binder(input.stream)
        }
    }
    /// Runs the given parser, return it's results (ignoring the current value).
    public func leftward<B>(_ parser: @autoclosure @escaping () -> Parser.IO<B>) -> Parser.IO<A> {
        self.and(parser()).map {$0.0}
    }
    /// Runs the given parser, ignore it's results.
    public func rightward<B>(_ parser: @autoclosure @escaping () -> Parser.IO<B>) -> Parser.IO<B> {
        self.and(parser()).map {$0.1}
    }
    public func inspect(_ f: @escaping (A) -> ()) -> Self {
        Self { input in
            let output = self.binder(input)
            if let a = output.value {
                f(a)
            }
            return .init(value: output.value, stream: output.stream)
        }
    }
}

