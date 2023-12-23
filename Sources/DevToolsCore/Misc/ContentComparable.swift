//
//  ContentComparable.swift
//
//
//  Created by Hardijs Ķirsis on 24/12/2023.
//

import Foundation

infix operator |==|: ComparisonPrecedence

public protocol ContentComparable {
    var contentHash: Int { get }
}

public func |==|<T: ContentComparable>(lhs: T, rhs: T) -> Bool {
    return lhs.contentHash == rhs.contentHash
}

public func |==|<T: ContentComparable>(lhs: [T], rhs: [T]) -> Bool {
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

// MARK: Example
fileprivate class CellViewModel {
    let id: String
    let title: String
    let text: String
    
    init(id: String, title: String, text: String) {
        self.id = id
        self.title = title
        self.text = text
    }
}

extension CellViewModel: ContentComparable {
    var contentHash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(text)
        return hasher.finalize()
    }
}

extension CellViewModel: Hashable {
    static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
