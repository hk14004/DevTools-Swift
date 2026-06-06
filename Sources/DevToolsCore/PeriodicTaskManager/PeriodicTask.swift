//
//  PeriodicTask.swift
//

import Foundation

/// A task that performs async work on a repeating schedule.
///
/// Conform to this protocol and pass instances to `PeriodicTaskManager.schedule(_:)`.
///
/// ```swift
/// struct FeedSyncTask: PeriodicTask {
///     let id = "feed.sync"
///     let interval: TimeInterval = .minutes(5)
///
///     private let repository: FeedRepository
///
///     init(repository: FeedRepository) {
///         self.repository = repository
///     }
///
///     func perform() async throws {
///         try await repository.sync()
///     }
/// }
/// ```
public protocol PeriodicTask: Sendable {
    /// A stable string that uniquely identifies this task.
    /// Scheduling a new task with the same `id` cancels the existing one.
    var id: String { get }

    /// How long to wait between the end of one execution and the start of the next.
    var interval: TimeInterval { get }

    /// The work to perform. Called once immediately when scheduled, then again
    /// after each `interval`. Throw to signal a failed execution — the error
    /// is forwarded to `PeriodicTaskManager`'s `onError` handler and the task
    /// continues running on its schedule.
    func perform() async throws
}
