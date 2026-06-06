//
//  Collection+Numeric.swift
//

import Foundation

// MARK: - Sum

public extension Collection where Element: Numeric {

    /// Returns the sum of all elements.
    ///
    /// Returns `.zero` for an empty collection.
    ///
    /// ```swift
    /// [1, 2, 3, 4].sum()                  // 10
    /// cartItems.map(\.price).sum()          // Decimal total
    /// measurements.map(\.value).sum()       // Double total
    /// ```
    func sum() -> Element {
        reduce(.zero, +)
    }
}

// MARK: - Average

public extension Collection where Element: BinaryFloatingPoint {

    /// Returns the arithmetic mean of all elements, or `nil` for an empty collection.
    ///
    /// ```swift
    /// [1.0, 2.0, 3.0].average()   // 2.0
    /// ratings.average()            // Double?
    /// ```
    func average() -> Element? {
        guard !isEmpty else { return nil }
        return sum() / Element(count)
    }
}

public extension Collection where Element: BinaryInteger {

    /// Returns the arithmetic mean as a `Double`, or `nil` for an empty collection.
    ///
    /// Each element is converted to `Double` during the fold to avoid integer
    /// overflow and to preserve fractional results.
    ///
    /// ```swift
    /// [1, 2, 3].average()      // 2.0
    /// scores.average()          // Double?
    /// ```
    func average() -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0.0) { $0 + Double($1) } / Double(count)
    }
}
