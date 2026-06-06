//
//  Publisher+FilterNil.swift
//

import Combine

extension Publisher {

    /// Unwraps optional values, discarding `nil`s.
    ///
    /// Equivalent to `compactMap { $0 }` but reads clearly at the call site:
    ///
    /// ```swift
    /// $searchText               // AnyPublisher<String?, Never>
    ///     .filterNil()          // AnyPublisher<String, Never>
    ///     .sink { print($0) }
    /// ```
    public func filterNil<T>() -> AnyPublisher<T, Failure> where Output == T? {
        compactMap { $0 }.eraseToAnyPublisher()
    }
}
