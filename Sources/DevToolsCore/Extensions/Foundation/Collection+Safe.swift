//
//  Collection + Ext.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import Foundation

public extension Collection {

    /// Returns the element at the given index, or `nil` if the index is out of bounds.
    ///
    /// Avoids index-out-of-bounds crashes when working with arrays of unknown length,
    /// such as URL path segments from a deep link.
    ///
    /// ```swift
    /// let segments = ["product", "42", "reviews"]
    /// segments[safe: 1]  // "42"
    /// segments[safe: 5]  // nil
    /// ```
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
