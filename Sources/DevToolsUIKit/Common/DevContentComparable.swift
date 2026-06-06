//
//  DevContentComparable.swift
//
//
//  Created by Hardijs Ķirsis on 24/12/2023.
//

import Foundation

infix operator |==|: ComparisonPrecedence

public protocol DevContentComparable {
    var contentHash: Int { get }
}

public func |==|<T: DevContentComparable>(lhs: T, rhs: T) -> Bool {
    return lhs.contentHash == rhs.contentHash
}

public func |==|<T: DevContentComparable>(lhs: [T], rhs: [T]) -> Bool {
    guard lhs.count == rhs.count else {
        return false
    }

    for (item1, item2) in zip(lhs, rhs) {
        if !(item1 |==| item2) {
            return false
        }
    }

    return true
}

public extension DevContentComparable {
    var contentHash: Int {
        var hasher = Hasher()
        let mirror = Mirror(reflecting: self)
        let children = mirror.children
        
        guard !children.isEmpty else {
            return String(describing: self).hashValue
        }
        
        for case let (_?, value) in children {
            if let value = value as? DevContentComparable {
                hasher.combine(value.contentHash)
                continue
            }
            if let hashable = value as? (any Hashable) {
                hasher.combine(hashable)
            }
        }
        
        return hasher.finalize()
    }
}

public extension Collection where Element: DevContentComparable {
    var contentHash: Int {
        var hasher = Hasher()
        forEach { hasher.combine($0.contentHash) }
        return hasher.finalize()
    }
}

