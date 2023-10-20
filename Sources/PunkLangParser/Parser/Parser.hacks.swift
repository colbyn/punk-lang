//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/18/23.
//

import Foundation

extension Parser {
    /// Chains together a sequence of heterogeneous parsers.
    public static func sequence<A, B>(
        _ parser1: @autoclosure @escaping () -> IO<A>,
        _ parser2: @autoclosure @escaping () -> IO<B>
    ) -> IO<(A, B)> {
        Parser.IO<(A, B)> { input in
            var stream = input
            var values: (A?, B?) = (nil, nil)
            
            switch parser1().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.0 = value
                stream = next
            }
            
            switch parser2().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.1 = value
                stream = next
            }
            
            let results: (A, B) = (values.0!, values.1!)
            return .ok(value: results, stream: stream)
        }
    }
    /// Chains together a sequence of heterogeneous parsers.
    public static func sequence<A, B, C>(
        _ parser1: @autoclosure @escaping () -> IO<A>,
        _ parser2: @autoclosure @escaping () -> IO<B>,
        _ parser3: @autoclosure @escaping () -> IO<C>
    ) -> IO<(A, B, C)> {
        Parser.IO<(A, B, C)> { input in
            var stream = input
            var values: (A?, B?, C?) = (nil, nil, nil)
            
            switch parser1().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.0 = value
                stream = next
            }
            
            switch parser2().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.1 = value
                stream = next
            }
            
            switch parser3().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.2 = value
                stream = next
            }
            
            let results: (A, B, C) = (values.0!, values.1!, values.2!)
            return .ok(value: results, stream: stream)
        }
    }
    /// Chains together a sequence of heterogeneous parsers.
    public static func sequence<A, B, C, D>(
        _ parser1: @autoclosure @escaping () -> IO<A>,
        _ parser2: @autoclosure @escaping () -> IO<B>,
        _ parser3: @autoclosure @escaping () -> IO<C>,
        _ parser4: @autoclosure @escaping () -> IO<D>
    ) -> IO<(A, B, C, D)> {
        Parser.IO<(A, B, C, D)> { input in
            var stream = input
            var values: (A?, B?, C?, D?) = (nil, nil, nil, nil)
            
            switch parser1().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.0 = value
                stream = next
            }
            
            switch parser2().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.1 = value
                stream = next
            }
            
            switch parser3().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.2 = value
                stream = next
            }
            
            switch parser4().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.3 = value
                stream = next
            }
            
            let results: (A, B, C, D) = (values.0!, values.1!, values.2!, values.3!)
            return .ok(value: results, stream: stream)
        }
    }
    /// Chains together a sequence of heterogeneous parsers.
    public static func sequence<A, B, C, D, E>(
        _ parser1: @autoclosure @escaping () -> IO<A>,
        _ parser2: @autoclosure @escaping () -> IO<B>,
        _ parser3: @autoclosure @escaping () -> IO<C>,
        _ parser4: @autoclosure @escaping () -> IO<D>,
        _ parser5: @autoclosure @escaping () -> IO<E>
    ) -> IO<(A, B, C, D, E)> {
        Parser.IO<(A, B, C, D, E)> { input in
            var stream = input
            var values: (A?, B?, C?, D?, E?) = (nil, nil, nil, nil, nil)
            
            switch parser1().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.0 = value
                stream = next
            }
            
            switch parser2().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.1 = value
                stream = next
            }
            
            switch parser3().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.2 = value
                stream = next
            }
            
            switch parser4().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.3 = value
                stream = next
            }
            
            switch parser5().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.4 = value
                stream = next
            }
            
            let results: (A, B, C, D, E) = (values.0!, values.1!, values.2!, values.3!, values.4!)
            return .ok(value: results, stream: stream)
        }
    }
    /// Chains together a sequence of heterogeneous parsers.
    public static func sequence<A, B, C, D, E, F>(
        _ parser1: @autoclosure @escaping () -> IO<A>,
        _ parser2: @autoclosure @escaping () -> IO<B>,
        _ parser3: @autoclosure @escaping () -> IO<C>,
        _ parser4: @autoclosure @escaping () -> IO<D>,
        _ parser5: @autoclosure @escaping () -> IO<E>,
        _ parser6: @autoclosure @escaping () -> IO<F>
    ) -> IO<(A, B, C, D, E, F)> {
        Parser.IO<(A, B, C, D, E, F)> { input in
            var stream = input
            var values: (A?, B?, C?, D?, E?, F?) = (nil, nil, nil, nil, nil, nil)
            
            switch parser1().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.0 = value
                stream = next
            }
            
            switch parser2().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.1 = value
                stream = next
            }
            
            switch parser3().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.2 = value
                stream = next
            }
            
            switch parser4().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.3 = value
                stream = next
            }
            
            switch parser5().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.4 = value
                stream = next
            }
            
            switch parser6().binder(stream) {
            case .err(_): return .err(stream: input)
            case .ok(let value, let next):
                values.5 = value
                stream = next
            }
            
            let results: (A, B, C, D, E, F) = (values.0!, values.1!, values.2!, values.3!, values.4!, values.5!)
            return .ok(value: results, stream: stream)
        }
    }
}
