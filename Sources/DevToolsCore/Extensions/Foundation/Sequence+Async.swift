//
//  Sequence+Async.swift
//

/// Async equivalents of the standard `map`, `compactMap`, `filter`, and `forEach`
/// operators — which Swift's stdlib only provides in synchronous form.
///
/// All four execute elements **sequentially**, one at a time. This is intentional:
/// sequential async is the safe default and matches the behaviour of their
/// synchronous counterparts. For parallel execution use `zipAll()` (same-type
/// publishers) or `withThrowingTaskGroup` (heterogeneous / large N).
///
/// ```swift
/// // Sequential — each fetch awaits the previous one
/// let posts = try await postIDs.asyncMap { try await api.fetchPost(id: $0) }
///
/// // Parallel — all fetches start simultaneously
/// let posts = try await postIDs.map { api.fetchPost(id: $0) }.zipAll()
/// ```

import Foundation

public extension Sequence {

    /// Returns an array of the results of applying `transform` to each element,
    /// awaiting each call before moving to the next.
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var results: [T] = []
        results.reserveCapacity(underestimatedCount)
        for element in self {
            try await results.append(transform(element))
        }
        return results
    }

    /// Returns an array of the non-nil results of applying `transform` to each
    /// element, awaiting each call before moving to the next.
    func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var results: [T] = []
        for element in self {
            if let value = try await transform(element) {
                results.append(value)
            }
        }
        return results
    }

    /// Returns the elements that satisfy `predicate`, awaiting each call before
    /// moving to the next.
    func asyncFilter(
        _ predicate: (Element) async throws -> Bool
    ) async rethrows -> [Element] {
        var results: [Element] = []
        for element in self {
            if try await predicate(element) {
                results.append(element)
            }
        }
        return results
    }

    /// Calls `operation` on each element in order, awaiting each call before
    /// moving to the next.
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
