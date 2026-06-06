import Foundation

/// The source of data for an upload request.
public enum UploadSource {
    /// Upload from an in-memory buffer. Suitable for small payloads.
    case data(Data)
    /// Upload from a file on disk. Preferred for large files — URLSession streams
    /// the bytes without loading the entire file into memory.
    case file(URL)
}
