//
//  Array + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 19/06/2023.
//

import Foundation

public extension Array {

    /// Splits the array into consecutive chunks of at most `size` elements.
    ///
    /// The last chunk may contain fewer than `size` elements if the array
    /// doesn't divide evenly.
    ///
    /// ```swift
    /// [1,2,3,4,5].chunked(into: 2)  // [[1,2], [3,4], [5]]
    /// items.chunked(into: 20)        // pages of 20 for a batch API call
    /// ```
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

public extension Array where Element: Hashable {

    /// Returns a new array with duplicate elements removed, preserving the
    /// order of first occurrence.
    ///
    /// Uses a `Set` for O(n) performance — the previous `Equatable`-only
    /// version was O(n²) due to repeated `contains` scans on the result array.
    ///
    /// ```swift
    /// [1, 2, 2, 3, 1].removingDuplicates() // [1, 2, 3]
    /// ```
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
