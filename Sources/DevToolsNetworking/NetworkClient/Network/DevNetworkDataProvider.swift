import Combine
import Foundation

public protocol DevNetworkDataProvider {
    typealias Output = URLSession.DataTaskPublisher.Output
    
    func output(for request: URLRequest) -> AnyPublisher<Output, URLError>
}

private class ExampleNetworkDataProvider: NSObject, DevNetworkDataProvider {
    lazy var session = URLSession(
        configuration: URLSessionConfiguration.default,
        delegate: self,
        delegateQueue: nil
    )
    
    public func output(for request: URLRequest) -> AnyPublisher<DevNetworkDataProvider.Output, URLError> {
        session.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

// MARK: - URLSessionDelegate
extension ExampleNetworkDataProvider: URLSessionDelegate {
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
