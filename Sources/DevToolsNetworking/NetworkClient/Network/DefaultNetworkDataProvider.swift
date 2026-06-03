import Combine
import Foundation

/// A default `DevNetworkDataProvider` backed by `URLSession`.
///
/// Uses the system's standard SSL certificate validation out of the box.
/// For SSL pinning or custom authentication challenges, supply a `URLSessionDelegate`:
///
/// ```swift
/// class PinningDelegate: NSObject, URLSessionDelegate {
///     func urlSession(
///         _ session: URLSession,
///         didReceive challenge: URLAuthenticationChallenge,
///         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
///     ) {
///         // Validate against your pinned certificate
///     }
/// }
///
/// let provider = DefaultNetworkDataProvider(delegate: PinningDelegate())
/// ```
public final class DefaultNetworkDataProvider: DevNetworkDataProvider, DevFileDownloadProvider {

    private let session: URLSession
    private let downloadCoordinator: DownloadCoordinator

    /// - Parameters:
    ///   - configuration: The session configuration. Defaults to `.default`.
    ///   - delegate: An optional delegate for custom authentication challenges such as SSL pinning.
    ///               When `nil`, the system performs standard certificate validation.
    public init(
        configuration: URLSessionConfiguration = .default,
        delegate: URLSessionDelegate? = nil
    ) {
        self.session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
        self.downloadCoordinator = DownloadCoordinator(configuration: configuration, authDelegate: delegate)
    }

    // MARK: - DevNetworkDataProvider

    public func output(for request: URLRequest) -> AnyPublisher<Output, URLError> {
        session.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }

    // MARK: - DevFileDownloadProvider

    public func download(for request: URLRequest) -> AnyPublisher<DownloadEvent, Error> {
        downloadCoordinator.download(request: request)
    }
}
