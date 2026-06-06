//
//  PeriodicTaskManager.swift
//

import Foundation

/// Schedules and manages repeating async tasks.
///
/// `actor` isolation guarantees that all state mutations — scheduling,
/// cancelling, tracking execution — are thread-safe with no manual locking.
///
/// ## Basic usage
///
/// ```swift
/// let manager = PeriodicTaskManager { id, error in
///     print("Task \(id) failed: \(error)")
/// }
///
/// await manager.schedule(FeedSyncTask(repository: feedRepo))
/// await manager.schedule(AnalyticsFlushTask())
///
/// // Later — cancel one
/// await manager.cancel(id: "feed.sync")
///
/// // Or cancel all on logout
/// await manager.cancelAll()
/// ```
///
/// ## Execution model
///
/// Each task runs immediately when scheduled, then repeats after its `interval`
/// elapses from the **end** of the previous execution (not a fixed clock tick).
/// This prevents tasks from piling up if work takes longer than the interval.
///
/// If `perform()` throws, the error is forwarded to `onError` and the task
/// continues on its next interval — a single failure does not stop the schedule.
public actor PeriodicTaskManager {

    // MARK: - Types

    /// Called on the cooperative thread pool when a task's `perform()` throws.
    public typealias ErrorHandler = @Sendable (String, any Error) -> Void

    private struct Entry {
        let handle: Task<Void, Never>
        var isExecuting: Bool = false
    }

    // MARK: - State

    private var entries: [String: Entry] = [:]
    private let onError: ErrorHandler?

    // MARK: - Init

    public init(onError: ErrorHandler? = nil) {
        self.onError = onError
    }

    // MARK: - Scheduling

    /// Schedules `task` to run immediately and repeat at `task.interval`.
    ///
    /// If a task with the same `id` is already scheduled it is cancelled first.
    public func schedule(_ task: some PeriodicTask) {
        cancel(id: task.id)

        let id       = task.id
        let interval = task.interval
        let onError  = self.onError

        let handle = Task {
            while !Task.isCancelled {
                entries[id]?.isExecuting = true
                do    { try await task.perform() }
                catch { onError?(id, error) }
                entries[id]?.isExecuting = false

                try? await Task.sleep(for: .seconds(interval))
            }
        }

        entries[id] = Entry(handle: handle)
    }

    /// Cancels the task with `id`. No-op if the task is not scheduled.
    public func cancel(id: String) {
        entries[id]?.handle.cancel()
        entries.removeValue(forKey: id)
    }

    /// Cancels all scheduled tasks.
    public func cancelAll() {
        entries.values.forEach { $0.handle.cancel() }
        entries.removeAll()
    }

    // MARK: - Inspection

    /// IDs of all currently scheduled tasks.
    public var scheduledIDs: [String] {
        Array(entries.keys)
    }

    /// `true` if the task with `id` is currently inside its `perform()` call.
    public func isExecuting(id: String) -> Bool {
        entries[id]?.isExecuting ?? false
    }
}
