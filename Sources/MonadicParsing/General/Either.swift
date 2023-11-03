//
//  File.swift
//  
//
//  Created by Colbyn Wadman on 10/17/23.
//

import Foundation

// MARK: - EITHER 1 -
public enum Either<Left, Right> {
    case left(Left)
    case right(Right)
}

extension Either {
    public var isLeft: Bool {
        switch self {
        case .left(_):
            return true
        case .right(_):
            return false
        }
    }
    public var isRight: Bool {
        switch self {
        case .left(_):
            return false
        case .right(_):
            return true
        }
    }
}

extension Either where Left == Right {
    public var into: Left {
        switch self {
        case .left(let left): return left
        case .right(let right): return right
        }
    }
}
