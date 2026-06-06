//
//  Comparable+Ext.swift
//

import Foundation

public extension Comparable {

    /// Returns the value clamped to the given closed range.
    ///
    /// Equivalent to `max(lowerBound, min(upperBound, value))` but reads as
    /// intent at the call site.
    ///
    /// ```swift
    /// (-5).clamped(to: 0...100)    // 0
    /// 42.clamped(to: 0...100)      // 42
    /// 150.clamped(to: 0...100)     // 100
    ///
    /// progress.clamped(to: 0.0...1.0)
    /// volume.clamped(to: 0...11)
    /// ```
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
