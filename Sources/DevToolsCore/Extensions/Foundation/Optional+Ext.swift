//
//  Optional+Ext.swift
//

import Foundation

public extension Optional {

    /// `true` if the optional is `nil`.
    ///
    /// Reads more naturally than `== nil` in filter/map chains and
    /// when assigning to a `Bool` property:
    ///
    /// ```swift
    /// items.filter { $0.subtitle.isNil }
    /// submitButton.isEnabled = selectedItem.isNotNil
    /// ```
    var isNil: Bool { self == nil }

    /// `true` if the optional holds a value.
    var isNotNil: Bool { self != nil }
}
