import Foundation

/// Events emitted by a file download publisher.
public enum DownloadEvent {
    /// Bytes are being received. `totalBytes` is `nil` when the server did not send `Content-Length`.
    case progress(bytesReceived: Int64, totalBytes: Int64?)
    /// The download has finished. The file is at `fileURL` in the temporary directory.
    /// Move it to a permanent location before the publisher completes or the OS may clean it up.
    case completed(fileURL: URL)
}

public extension DownloadEvent {
    /// A 0.0–1.0 fraction of download progress, or `nil` when total size is unknown.
    var progressFraction: Double? {
        guard case .progress(let received, let total?) = self, total > 0 else { return nil }
        return Double(received) / Double(total)
    }
}
