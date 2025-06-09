import Combine
import Foundation
import DevToolsCore

public protocol DevNetworkClient: AnyObject {
    func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error>
}

open class BaseNetworkClient: DevNetworkClient {
    // MARK: - Variables
    private let dataProvider: DevNetworkDataProvider
    private let requestFactory: DevNetworkRequestFactory
    private let authorizationHeaderProvider: DevAuthorizationHeaderProvider
    
    // MARK: - Methods
    public init(
        dataProvider: DevNetworkDataProvider,
        requestFactory: DevNetworkRequestFactory,
        authorizationHeaderProvider: DevAuthorizationHeaderProvider
    ) {
        self.requestFactory = requestFactory
        self.dataProvider = dataProvider
        self.authorizationHeaderProvider = authorizationHeaderProvider
    }
}

// MARK: Public
extension BaseNetworkClient {
    public func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error> {
        prepareRequest(with: requestConfig)
            .flatMap { [weak self] request -> AnyPublisher<T, Error> in
                self?.executeRequest(request: request) ?? .empty()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: Private
extension BaseNetworkClient {
    private func prepareRequest(with config: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        let authorizationHeaders = config.requiresAuthorization
        ? authorizationHeaderProvider.getAuthorizationHeaders()
        : .just(nil)
        
        return authorizationHeaders
            .flatMap { headers -> AnyPublisher<URLRequest, Error> in
                return .just(
                    self.requestFactory.urlRequest(
                        requestConfig: config,
                        authorizationHeaders: headers
                    )
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func executeRequest<T: Codable>(request: URLRequest) -> AnyPublisher<T, Error> {
        dataProvider.output(for: request)
            .decode(when: request)
            .eraseToAnyPublisher()
    }
}
