//
//  Publisher+FlatMapLatest.swift
//

import Combine

extension Publisher {

    /// Transforms each value into a publisher, automatically cancelling the
    /// previous inner publisher when a new value arrives.
    ///
    /// This is `map(transform).switchToLatest()` composed into a single readable
    /// operator — the Combine equivalent of RxSwift's `flatMapLatest`.
    ///
    /// The primary use case is any "latest-wins" async operation: search-as-you-type,
    /// debounced API calls, tab switches that load data, etc. Without this, stale
    /// in-flight work from previous values continues running and may overwrite newer
    /// results.
    ///
    /// ```swift
    /// // Search: only the response for the latest query is delivered.
    /// $searchText
    ///     .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    ///     .flatMapLatest { query in
    ///         api.search(query)
    ///     }
    ///     .sink { results in updateUI(results) }
    ///     .store(in: &cancellables)
    ///
    /// // Tab switch: previous tab's network call is cancelled.
    /// $selectedTab
    ///     .flatMapLatest { tab in
    ///         api.loadContent(for: tab)
    ///     }
    ///     .sink { content in render(content) }
    ///     .store(in: &cancellables)
    /// ```
    public func flatMapLatest<P: Publisher>(
        _ transform: @escaping (Output) -> P
    ) -> AnyPublisher<P.Output, Failure> where P.Failure == Failure {
        map(transform)
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
