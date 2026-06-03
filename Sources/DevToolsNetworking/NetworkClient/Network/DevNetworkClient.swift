import Combine
import Foundation
import DevToolsCore

public protocol DevNetworkClient: AnyObject {
    func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error>
}

open class BaseNetworkClient: DevNetworkClient {
    // MARK: - Variables
    public let dataProvider: DevNetworkDataProvider
    public let requestFactory: DevNetworkRequestFactory
    public let reachabilityNotifier: NetworkReachability
    
    // MARK: - Methods
    public init(
        dataProvider: DevNetworkDataProvider,
        requestFactory: DevNetworkRequestFactory,
        reachabilityNotifier: NetworkReachability
    ) {
        self.requestFactory = requestFactory
        self.dataProvider = dataProvider
        self.reachabilityNotifier = reachabilityNotifier
    }
    
    open func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error> {
        guard reachabilityNotifier.isReachable else {
            return .fail(NetworkError.reachability)
        }
        return prepareRequest(requestConfig: requestConfig)
            .flatMap { [weak self] request in
                self?.dataProvider.output(for: request)
                    .decode(when: request) ?? .empty()
            }
            .eraseToAnyPublisher()
    }
    
    open var authorizationHeaderProvider: DevAuthorizationHeaderProvider? { nil }

    open func prepareRequest(requestConfig: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        guard requestConfig.requiresAuthorization, let provider = authorizationHeaderProvider else {
            return .just(requestFactory.urlRequest(requestConfig: requestConfig, authorizationHeaders: nil))
        }
        return provider.getAuthorizationHeaders()
            .map { self.requestFactory.urlRequest(requestConfig: requestConfig, authorizationHeaders: $0) }
            .eraseToAnyPublisher()
    }
}
