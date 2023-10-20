//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/18/23.
//

import Foundation

extension Parser {
    public enum State<A> {
        case ok(value: A, stream: Text)
        case err(stream: Text)
    }
}

extension Parser.State {
    internal var stream: Parser.Text {
        switch self {
        case .ok(_, let stream): return stream
        case .err(let stream): return stream
        }
    }
    internal var tuple: (A?, Parser.Text) {
        switch self {
        case .ok(let value, let stream): return (value, stream)
        case .err(let stream): return (nil, stream)
        }
    }
    internal init(from tuple: (A?, Parser.Text)) {
        if let a = tuple.0 {
            self = .ok(value: a, stream: tuple.1)
        } else {
            self = .err(stream: tuple.1)
        }
    }
    internal init(value: A?, stream: Parser.Text) {
        if let value = value {
            self = .ok(value: value, stream: stream)
        } else {
            self = .err(stream: stream)
        }
    }
    public var value: A? {
        switch self {
        case .ok(let value, _): return value
        case .err(_): return nil
        }
    }
    public func map<B>(_ f: @escaping (A) -> B) -> Parser.State<B> {
        switch self {
        case .ok(let value, let stream): return .ok(value: f(value), stream: stream)
        case .err(let stream): return .err(stream: stream)
        }
    }
    /// Returns the `ok` value or maps `err` to `ok` using the provided 'fallback' value.
    public func or(fallback: @autoclosure () -> A) -> Parser.State<A> {
        switch self {
        case .ok(let value, let stream): return .ok(value: value, stream: stream)
        case .err(let stream): return .ok(value: fallback(), stream: stream)
        }
    }
    /// Forgets the current state, replaces the `ok` value or maps `err` to `ok` with the given value.
    public func forget<B>(new value: B) -> Parser.State<B> {
        Parser.State<B>(from: (value, stream))
    }
}
