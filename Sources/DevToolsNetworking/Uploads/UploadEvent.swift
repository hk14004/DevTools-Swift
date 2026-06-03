import Foundation

/// Events emitted by `BaseNetworkClient.upload(_:source:)`.
public enum UploadEvent<T: Codable> {
    /// Bytes are being sent. Use `progressFraction` for a 0.0–1.0 value.
    case progress(bytesSent: Int64, totalBytes: Int64)
    /// Upload complete and server response decoded into `T`.
    case response(T)
}

public extension UploadEvent {
    /// A 0.0–1.0 fraction of upload progress, or `nil` for non-progress events.
    var progressFraction: Double? {
        guard case .progress(let sent, let total) = self, total > 0 else { return nil }
        return Double(sent) / Double(total)
    }
}
