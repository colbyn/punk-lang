//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

enum ParseError {
    case empty, noMatch
}
enum Status {
    case ok, error
}
enum Output<A> {
    case ok(A, Stream)
    case err([ParseError], Stream)
}

extension Output {
    var isOk: Bool {
        switch self {
        case .ok: return true
        case .err: return false
        }
    }
    var isErr: Bool {
        switch self {
        case .ok: return false
        case .err: return true
        }
    }
    func andThen<B>(f: @escaping (A, Stream) -> Output<B>) -> Output<B> {
        switch self {
        case .ok(let a, let s):
            return f(a, s)
        case .err(let e, let s):
            return .err(e, s)
        }
    }
    func map<B>(f: @escaping (A) -> B) -> Output<B> {
        switch self {
        case .ok(let a, let s):
            return .ok(f(a), s)
        case .err(let e, let s):
            return .err(e, s)
        }
    }
    func mapWithContext<B>(f: @escaping (A, Stream) -> B) -> Output<B> {
        switch self {
        case .ok(let a, let s):
            return .ok(f(a, s), s)
        case .err(let e, let s):
            return .err(e, s)
        }
    }
}

// MARK: - DEBUG -
extension ParseError: ToDebugTree {
    var debugTree: DebugTree {
        switch self {
        case .empty: return .label("ParseError.empty")
        case .noMatch: return .label("ParseError.noMatch")
        }
    }
}
extension Output: ToDebugTree where A: ToDebugTree {
    var debugTree: DebugTree {
        switch self {
        case .ok(let ok, let stream):
            return DebugTree(
                label: "Stream",
                children: [
                    .branch(.init(label: "ok", children: [ok.debugTree])),
                    .branch(.init(label: "stream", children: [stream.debugTree])),
                ]
            )
        case .err(let error, let stream):
            return DebugTree(
                label: "Stream",
                children: [
                    .branch(.init(label: "error", children: [error.debugTree])),
                    .branch(.init(label: "stream", children: [stream.debugTree])),
                ]
            )
        }
    }
}

