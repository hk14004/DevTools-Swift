import Foundation

/// Raw upload events emitted by `DevFileUploadProvider`.
/// `BaseNetworkClient` decodes the completed response into a typed `UploadEvent<T>`.
public enum UploadProgressEvent {
    /// Bytes are being sent to the server.
    case progress(bytesSent: Int64, totalBytes: Int64)
    /// All bytes have been sent and the server response has been received.
    case completed(data: Data, response: URLResponse)
}
