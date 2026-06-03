import Combine
import Foundation

/// A network client that supports file uploads with progress reporting.
///
/// Extend `DevNetworkClient` with this protocol when a service needs upload capability.
/// `BaseNetworkClient` conforms to this out of the box.
///
/// ```swift
/// final class MediaService {
///     private let client: any DevUploadClient
///
///     init(client: any DevUploadClient) {
///         self.client = client
///     }
/// }
/// ```
public protocol DevUploadClient: DevNetworkClient {
    func upload<T: Codable>(
        _ requestConfig: DevRequestConfig,
        source: UploadSource
    ) -> AnyPublisher<UploadEvent<T>, Error>
}
