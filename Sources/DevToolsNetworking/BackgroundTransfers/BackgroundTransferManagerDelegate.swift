import Foundation

/// Receives callbacks from `BackgroundTransferManager` for scheduled transfers.
///
/// The delegate is the correct pattern here — unlike regular requests, background transfers
/// survive app suspension and relaunch. A Combine subscriber would be gone after relaunch,
/// so the delegate is set once at startup and persists across the full transfer lifecycle.
///
/// Implement this on a long-lived object such as a coordinator or app-level service.
public protocol BackgroundTransferManagerDelegate: AnyObject {

    /// Called when a background download finishes successfully.
    /// Move the file from `fileURL` to a permanent location — it is in the temp directory
    /// and will be deleted when this method returns.
    func backgroundTransferManager(
        _ manager: BackgroundTransferManager,
        downloadDidFinish taskDescription: String,
        fileURL: URL
    )

    /// Called when a background upload finishes successfully.
    func backgroundTransferManager(
        _ manager: BackgroundTransferManager,
        uploadDidFinish taskDescription: String
    )

    /// Called as bytes are transferred. `progress` is 0.0–1.0, or `nil` when the
    /// total size is unknown.
    func backgroundTransferManager(
        _ manager: BackgroundTransferManager,
        task taskDescription: String,
        didUpdateProgress progress: Double?
    )

    /// Called when a transfer fails.
    func backgroundTransferManager(
        _ manager: BackgroundTransferManager,
        task taskDescription: String,
        didFailWith error: Error
    )
}

// Default no-op so progress is optional to implement.
public extension BackgroundTransferManagerDelegate {
    func backgroundTransferManager(
        _ manager: BackgroundTransferManager,
        task taskDescription: String,
        didUpdateProgress progress: Double?
    ) {}
}
