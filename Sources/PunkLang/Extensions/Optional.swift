//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/16/23.
//

import Foundation

extension Optional {
    var isNone: Bool {
        switch self {
        case .none: return true
        case .some(_): return false
        }
    }
    var isSome: Bool {
        switch self {
        case .none: return false
        case .some(_): return true
        }
    }
    func unwrap(or: @autoclosure () -> Wrapped) -> Wrapped {
        if let this = self {
            return this
        }
        return or()
    }
    func map<T>(f: @escaping (Wrapped) -> T) -> Optional<T> {
        if let this = self {
            return .some(f(this))
        }
        return .none
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        if self == nil {
            return true
        }
        return self?.isEmpty == true
    }
}


