//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

// MARK: - API -
extension Monad {
    func map<B>(_ f: @escaping (A) -> B) -> Monad<B> {
        Monad<B> { s in
            switch self.binder(s) {
            case .ok(let a, let s):
                return .ok(f(a), s)
            case .err(let e, let s):
                return .err(e, s)
            }
        }
    }
    func then<B>(_ f: @escaping (A) -> Monad<B>) -> Monad<B> {
        Monad<B> { s in
            //            if s.view.isEmpty {
            //                return .err([.empty], s)
            //            }
            switch self.binder(s) {
            case .ok(let a, let s):
                switch f(a).binder(s) {
                case .ok(let b, let s): return .ok(b, s)
                case .err(let e, let s): return .err(e, s)
                }
            case .err(let e, let s):
                return .err(e, s)
            }
        }
    }
    func `guard`(pred f: @escaping (A) -> Either<ParseError, A>) -> Self {
        Monad { s in
            let origional = s
            switch self.binder(s) {
            case .ok(let a, let s):
                switch f(a) {
                case .right(let a): return .ok(a, s)
                case .left(let e): return .err([e], origional)
                }
            case .err(let e, let s):
                return .err(e, s)
            }
        }
    }
    func guardMap<B>(pred f: @escaping (A) -> Either<ParseError, B>) -> Monad<B> {
        Monad<B> { s1 in
            switch self.binder(s1) {
            case .ok(let a, let s2):
                switch f(a) {
                case .right(let b): return .ok(b, s2)
                case .left(let e): return .err([e], s2)
                }
            case .err(let e, let s):
                return .err(e, s)
            }
        }
    }
}

// MARK: - GENERAL PARSER COMBINATORS -
extension Monad {
    func recover(_ f: @escaping (Stream) -> A) -> Monad<A> {
        Monad<A> { s1 in
            let result = self.binder(s1)
            switch result {
            case .err(_, let s2):
                return .ok(f(s2), s2)
            case .ok(let value, let s2):
                return .ok(value, s2)
            }
        }
    }
    func recover(value: A) -> Monad<A> {
        self.recover { _ in value }
    }
    func forget<B>(return override: @autoclosure @escaping () -> B) -> Monad<B> {
        Monad<B> { s1 in
            switch self.binder(s1) {
            case .err(let e, let s2): return .err(e, s2)
            case .ok(_, let s2): return .ok(override(), s2)
            }
        }
    }
    /// Forgets the current value, returns the next value.
    func keepRight<B>(_ override: @autoclosure @escaping () ->  Monad<B>) -> Monad<B> {
        Monad<B> { s1 in
            switch self.binder(s1) {
            case .err(let e, let s2): return .err(e, s2)
            case .ok(_, let s2):
                switch override().binder(s2) {
                case .err(let e, let s3): return .err(e, s3)
                case .ok(let b, let s3): return .ok(b, s3)
                }
            }
        }
    }
    /// Run the given parser and forget the value, keeping the origional value.
    func keepLeft<B>(_ next: @autoclosure @escaping () ->  Monad<B>) -> Monad<A> {
        Monad<A> { s1 in
            switch self.binder(s1) {
            case .err(let e, let s2): return .err(e, s2)
            case .ok(let a, let s2):
                switch next().binder(s2) {
                case .err(let e, let s3): return .err(e, s3)
                case .ok(_, let s3): return .ok(a, s3)
                }
            }
        }
    }
    func and<B>(_ next: @autoclosure @escaping () -> Monad<B>) -> Monad<(A, B)> {
        Monad<(A, B)> { s1 in
            switch self.binder(s1) {
            case .ok(let a, let s2):
                switch next().binder(s2) {
                case .ok(let b, let s3): return .ok((a, b), s3)
                case .err(let e, let stream): return .err(e, stream)
                }
            case .err(let e, let stream): return .err(e, stream)
            }
        }
    }
    func andTry<B>(_ next: @autoclosure @escaping () -> Monad<B?>) -> Monad<(A, B?)> {
        Monad<(A, B?)> { s1 in
            switch self.binder(s1) {
            case .ok(let a, let s2):
                switch next().binder(s2) {
                case .ok(let b, let s3):
                    return .ok((a, b), s3)
                case .err(_, _):
                    return .ok((a, nil), s2)
                }
            case .err(let e, _):
                return .err(e, s1)
            }
        }
    }
    func and2<B, C>(_ first: @autoclosure @escaping () -> Monad<B>, _ second: @autoclosure @escaping () -> Monad<C>) -> Monad<(A, B, C)> {
        self.and(first()).and(second()).map {
            ($0.0.0, $0.0.1, $0.1)
        }
    }
    func and3<B, C, D>(
        first: @autoclosure @escaping () -> Monad<B>,
        second: @autoclosure @escaping () -> Monad<C>,
        third: @autoclosure @escaping () -> Monad<D>
    ) -> Monad<(A, B, C, D)> {
        self.and2(first(), second()).and(third()).map {
            ($0.0.0, $0.0.1, $0.0.2, $0.1)
        }
    }
    func many<B>(parser: @autoclosure @escaping () -> Monad<B>) -> Monad<(A, [B])> {
        self.then { a in
            Parser.many(parser()).map {b in (a, b)}
        }
    }
    func some<B>(parser: @autoclosure @escaping () -> Monad<B>) -> Monad<(A, [B])> {
        self.then { a in
            Parser.some(parser()).map {b in (a, b)}
        }
    }
    func either<B, C>(
        _ parser1: @autoclosure @escaping () -> Monad<B>,
        _ parser2: @autoclosure @escaping () -> Monad<C>
    ) -> Monad<(A, Either<B, C>)> {
        self.then { a in
            Parser.either(left: parser1(), right: parser2()).map {either in (a, either)}
        }
    }
}
