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
    
    // MARK: - Methods
    public init(
        dataProvider: DevNetworkDataProvider,
        requestFactory: DevNetworkRequestFactory
    ) {
        self.requestFactory = requestFactory
        self.dataProvider = dataProvider
    }
}

// MARK: Public
extension BaseNetworkClient {
    public func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error> {
        prepareRequest(with: requestConfig)
            .flatMap { [weak self] request -> AnyPublisher<T, Error> in
                self?.executeRequest(request: request) ?? .empty()
            }
            .tryCatch { [weak self] error -> AnyPublisher<T, Error> in
                self?.catchRequestError(
                    requestConfig: requestConfig,
                    error: error
                ) ?? .empty()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: Private
extension BaseNetworkClient {
    private func prepareRequest(with config: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        .just(
            requestFactory.urlRequest(
                requestConfig: config
            )
        ).eraseToAnyPublisher()
    }
    
    private func executeRequest<T: Codable>(request: URLRequest) -> AnyPublisher<T, Error> {
        dataProvider.output(for: request)
            .decode(when: request)
            .eraseToAnyPublisher()
    }
    
    private func catchRequestError<T>(
        requestConfig: DevRequestConfig,
        error: Error
    ) -> AnyPublisher<T, Error> {
        switch error {
        case NetworkError.unauthorized:
            return .fail(error)
        case NetworkError.forbidden:
            return .fail(error)
        default:
            return .fail(error)
        }
    }
}
