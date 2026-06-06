//
//  Dictionary+Ext.swift
//

import Foundation

public extension Dictionary {

    /// Returns a new dictionary with all keys transformed by `transform`.
    ///
    /// Swift's stdlib provides `mapValues` but not `mapKeys`. If two keys
    /// transform to the same new key the last one wins — use the overload
    /// with `uniquingKeysWith` if you need explicit collision handling.
    ///
    /// ```swift
    /// apiResponse.mapKeys { $0.lowercased() }
    /// headers.mapKeys { $0.replacingOccurrences(of: "-", with: "_") }
    /// ```
    func mapKeys<NewKey: Hashable>(
        _ transform: (Key) throws -> NewKey
    ) rethrows -> [NewKey: Value] {
        try reduce(into: [:]) { result, pair in
            result[try transform(pair.key)] = pair.value
        }
    }

    /// Returns a new dictionary with all keys transformed, using `combine`
    /// to resolve collisions when two keys map to the same new key.
    ///
    /// ```swift
    /// dict.mapKeys({ $0.lowercased() }, uniquingKeysWith: { _, new in new })
    /// ```
    func mapKeys<NewKey: Hashable>(
        _ transform: (Key) throws -> NewKey,
        uniquingKeysWith combine: (Value, Value) throws -> Value
    ) rethrows -> [NewKey: Value] {
        try Dictionary<NewKey, Value>(
            map { (try transform($0.key), $0.value) },
            uniquingKeysWith: combine
        )
    }
}
