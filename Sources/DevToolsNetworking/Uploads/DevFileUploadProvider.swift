import Combine
import Foundation

/// An opt-in capability for data providers that support file uploads with progress.
///
/// `DefaultNetworkDataProvider` conforms to this protocol out of the box.
public protocol DevFileUploadProvider {
    func upload(request: URLRequest, source: UploadSource) -> AnyPublisher<UploadProgressEvent, Error>
}
