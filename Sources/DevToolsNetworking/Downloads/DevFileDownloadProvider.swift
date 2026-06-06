import Combine
import Foundation

/// An opt-in capability for data providers that support file downloads with progress.
///
/// `DefaultNetworkDataProvider` conforms to this protocol out of the box.
/// If you implement your own `DevNetworkDataProvider`, adopt this protocol too
/// to unlock `BaseNetworkClient.download(_:)`.
public protocol DevFileDownloadProvider {
    func download(for request: URLRequest) -> AnyPublisher<DownloadEvent, Error>
}
