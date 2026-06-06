//
//  Publisher+WithPrevious.swift
//

import Combine

extension Publisher {

    /// Emits `(previous, current)` pairs on each new value.
    ///
    /// `previous` is `nil` for the very first emission, then holds the last
    /// seen value for every subsequent one. Useful for detecting what changed
    /// between two states without maintaining external state in the subscriber.
    ///
    /// ```swift
    /// store.$items
    ///     .withPrevious()
    ///     .sink { previous, current in
    ///         let added   = current.filter { !( previous ?? [] ).contains($0) }
    ///         let removed = (previous ?? []).filter { !current.contains($0) }
    ///     }
    /// ```
    ///
    /// - Note: Uses a single captured variable — safe for single-subscriber use,
    ///   which covers the vast majority of Combine pipelines.
    public func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        var previous: Output?
        return map { current -> (previous: Output?, current: Output) in
            defer { previous = current }
            return (previous: previous, current: current)
        }
        .eraseToAnyPublisher()
    }
}
