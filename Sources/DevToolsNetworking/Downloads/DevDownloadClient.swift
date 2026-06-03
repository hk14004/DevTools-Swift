import Combine
import Foundation

/// A network client that supports file downloads with progress reporting.
///
/// Extend `DevNetworkClient` with this protocol when a service needs download capability.
/// `BaseNetworkClient` conforms to this out of the box.
///
/// ```swift
/// // Declare only what the service needs — no unnecessary surface area.
/// final class FileService {
///     private let client: any DevDownloadClient
///
///     init(client: any DevDownloadClient) {
///         self.client = client
///     }
/// }
/// ```
public protocol DevDownloadClient: DevNetworkClient {
    func download(_ requestConfig: DevRequestConfig) -> AnyPublisher<DownloadEvent, Error>
}
