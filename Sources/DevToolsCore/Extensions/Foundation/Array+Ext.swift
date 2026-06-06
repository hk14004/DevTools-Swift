//
//  Array + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 19/06/2023.
//

import Foundation

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
