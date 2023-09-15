import Combine
import Foundation

public protocol NetworkDataProvider {
    typealias Output = URLSession.DataTaskPublisher.Output
    
    func output(for request: URLRequest) -> AnyPublisher<Output, URLError>
}

public final class DefaultNetworkDataProvider: NSObject, NetworkDataProvider {
    lazy var session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate: self,
        delegateQueue: nil
    )
    
    public func output(for request: URLRequest) -> AnyPublisher<NetworkDataProvider.Output, URLError> {
        session.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

// MARK: - URLSessionDelegate
extension DefaultNetworkDataProvider: URLSessionDelegate {
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let trust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let urlCredential = URLCredential(trust: trust)
        completionHandler(.useCredential, urlCredential)
    }
}
