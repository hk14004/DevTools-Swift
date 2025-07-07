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
    public let reachabilityNotifier: ReachabilityNotifier
    
    // MARK: - Methods
    public init(
        dataProvider: DevNetworkDataProvider,
        requestFactory: DevNetworkRequestFactory,
        reachabilityNotifier: ReachabilityNotifier
    ) {
        self.requestFactory = requestFactory
        self.dataProvider = dataProvider
        self.reachabilityNotifier = reachabilityNotifier
    }
    
    open func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error> {
        guard reachabilityNotifier.isReachable.value else {
            return .fail(NetworkError.reachability)
        }
        return prepareRequest(requestConfig: requestConfig)
            .flatMap { [weak self] request in
                self?.dataProvider.output(for: request)
                    .decode(when: request) ?? .empty()
            }
            .eraseToAnyPublisher()
    }
    
    open func prepareRequest(requestConfig: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        .just(
            requestFactory.urlRequest(
                requestConfig: requestConfig,
                authorizationHeaders: nil
            )
        )
    }
}
