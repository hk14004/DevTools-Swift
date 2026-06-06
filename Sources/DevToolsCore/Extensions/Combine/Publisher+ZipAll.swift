//
//  Publisher+ZipAll.swift
//

import Combine

extension Collection where Element: Publisher {

    /// Runs all publishers **in parallel**, then delivers a single array of results
    /// in the **same order as the input**, once every publisher has completed.
    ///
    /// This is the N-publisher equivalent of `Publishers.Zip` — which only
    /// supports up to 4 publishers natively.
    ///
    /// ⚠️ **Same-type only.** Every publisher in the collection must return the
    /// same `Output` type. For heterogeneous parallel requests (e.g. posts +
    /// messages + users simultaneously), use `async let` instead:
    ///
    /// ```swift
    /// async let posts    = api.fetchPosts()
    /// async let messages = api.fetchMessages()
    /// async let users    = api.fetchUsers()
    /// let (p, m, u) = try await (posts, messages, users)
    /// ```
    ///
    /// Under the hood it folds a zip chain: `zip(p0, p1, p2, ...)`. All publishers
    /// are subscribed to simultaneously (parallel execution), but results are
    /// assembled in input order regardless of which finishes first.
    ///
    /// If **any** publisher fails the whole chain fails immediately and remaining
    /// in-flight work is cancelled.
    ///
    /// ```swift
    /// // Fetch 10 posts in parallel, get results back in the original order
    /// let publishers = postIDs.map { id in api.fetchPost(id: id) }
    ///
    /// publishers
    ///     .zipAll()
    ///     .receive(on: DispatchQueue.main)
    ///     .sink(receiveValue: { self.posts = $0 },
    ///           completionError: { self.error = $0 })
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// - Note: For very large collections (100+) consider `async/await` with
    ///   `withThrowingTaskGroup` instead — it has lower overhead at scale.
    func zipAll() -> AnyPublisher<[Element.Output], Element.Failure> {
        let empty = Just([Element.Output]())
            .setFailureType(to: Element.Failure.self)
            .eraseToAnyPublisher()

        return reduce(empty) { accumulated, next in
            accumulated
                .zip(next) { results, value in results + [value] }
                .eraseToAnyPublisher()
        }
    }
}
