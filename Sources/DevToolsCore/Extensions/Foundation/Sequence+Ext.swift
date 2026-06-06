//
//  Sequence+Ext.swift
//

import Foundation

// MARK: - Sorting by KeyPath

public extension Sequence {

    /// Returns the elements sorted by the given key path in ascending order.
    ///
    /// ```swift
    /// users.sorted(by: \.lastName)
    /// products.sorted(by: \.price)
    /// ```
    func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }

    /// Returns the elements sorted by the given key path in the specified order.
    ///
    /// ```swift
    /// users.sorted(by: \.createdAt, order: .reverse)   // newest first
    /// products.sorted(by: \.price, order: .forward)    // cheapest first
    /// ```
    func sorted<Value: Comparable>(
        by keyPath: KeyPath<Element, Value>,
        order: SortOrder
    ) -> [Element] {
        sorted { lhs, rhs in
            order == .forward
                ? lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
                : lhs[keyPath: keyPath] > rhs[keyPath: keyPath]
        }
    }
}

// MARK: - Min / Max by KeyPath

public extension Sequence {

    /// Returns the element with the smallest value at the given key path,
    /// or `nil` if the sequence is empty.
    ///
    /// ```swift
    /// players.min(by: \.score)
    /// products.min(by: \.price)
    /// ```
    func min<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> Element? {
        self.min { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }

    /// Returns the element with the largest value at the given key path,
    /// or `nil` if the sequence is empty.
    ///
    /// ```swift
    /// players.max(by: \.score)
    /// products.max(by: \.price)
    /// ```
    func max<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> Element? {
        self.max { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}

// MARK: - Grouping

public extension Sequence {

    /// Groups elements by the value at the given key path.
    ///
    /// A clean method-form alternative to `Dictionary(grouping:by:)`.
    ///
    /// ```swift
    /// messages.grouped(by: \.senderID)
    /// // → [userID: [Message]]
    ///
    /// transactions.grouped(by: \.date.startOfDay)
    /// // → [Date: [Transaction]]
    /// ```
    func grouped<Key: Hashable>(
        by keyPath: KeyPath<Element, Key>
    ) -> [Key: [Element]] {
        Dictionary(grouping: self) { $0[keyPath: keyPath] }
    }

    /// Groups elements using a transform closure.
    ///
    /// ```swift
    /// messages.grouped { $0.date.startOfDay() }
    /// items.grouped { $0.price > 100 ? .expensive : .affordable }
    /// ```
    func grouped<Key: Hashable>(
        by transform: (Element) -> Key
    ) -> [Key: [Element]] {
        Dictionary(grouping: self, by: transform)
    }
}

// MARK: - KeyPath find & filter

public extension Sequence {

    /// Returns the first element whose value at `keyPath` equals `value`.
    ///
    /// ```swift
    /// users.first(where: \.id, equals: targetID)
    /// products.first(where: \.sku, equals: "ABC-123")
    /// ```
    func first<Value: Equatable>(
        where keyPath: KeyPath<Element, Value>,
        equals value: Value
    ) -> Element? {
        first { $0[keyPath: keyPath] == value }
    }

    /// Returns all elements whose value at `keyPath` equals `value`.
    ///
    /// ```swift
    /// users.filter(by: \.status, equals: .active)
    /// orders.filter(by: \.isPaid, equals: true)
    /// ```
    func filter<Value: Equatable>(
        by keyPath: KeyPath<Element, Value>,
        equals value: Value
    ) -> [Element] {
        filter { $0[keyPath: keyPath] == value }
    }

    /// Returns the elements with duplicate values at `keyPath` removed,
    /// preserving the order of first occurrence.
    ///
    /// Unlike `removingDuplicates()`, this works for any key path — the element
    /// itself does not need to be `Hashable`.
    ///
    /// ```swift
    /// users.unique(by: \.id)         // deduplicate by ID
    /// events.unique(by: \.date.startOfDay)  // one event per day
    /// ```
    func unique<Value: Hashable>(
        by keyPath: KeyPath<Element, Value>
    ) -> [Element] {
        var seen = Set<Value>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
