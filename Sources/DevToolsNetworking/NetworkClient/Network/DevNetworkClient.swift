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
    public let plugins: [any NetworkClientPlugin]

    // MARK: - Init
    public init(
        dataProvider: DevNetworkDataProvider,
        requestFactory: DevNetworkRequestFactory,
        reachabilityNotifier: NetworkReachability,
        plugins: [any NetworkClientPlugin] = []
    ) {
        self.requestFactory = requestFactory
        self.dataProvider = dataProvider
        self.reachabilityNotifier = reachabilityNotifier
        self.plugins = plugins
    }

    // MARK: - Execute
    open func execute<T: Codable>(_ requestConfig: DevRequestConfig) -> AnyPublisher<T, Error> {
        guard reachabilityNotifier.isReachable else {
            return .fail(NetworkError.reachability)
        }
        return prepareRequest(requestConfig: requestConfig)
            .flatMap { [weak self] request -> AnyPublisher<T, Error> in
                guard let self else { return .empty() }
                self.plugins.forEach { $0.willSend(request, config: requestConfig) }
                return self.dataProvider.output(for: request)
                    .mapError { $0 as Error }
                    .map { Result<NetworkResponse, Error>.success($0) }
                    .catch { Just(Result<NetworkResponse, Error>.failure($0)) }
                    .setFailureType(to: Error.self)
                    .flatMap { [weak self] result -> AnyPublisher<NetworkResponse, Error> in
                        guard let self else { return .empty() }
                        self.plugins.forEach { $0.didReceive(result, config: requestConfig) }
                        let processed = self.plugins.reduce(result) { $1.process($0, config: requestConfig) }
                        switch processed {
                        case .success(let output): return .just(output)
                        case .failure(let error): return .fail(error)
                        }
                    }
                    .decode(when: request)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Request preparation
    open func prepareRequest(requestConfig: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        let base = requestFactory.urlRequest(requestConfig: requestConfig, authorizationHeaders: nil)
        return plugins.reduce(.just(base)) { chain, plugin in
            chain.flatMap { plugin.prepare($0, config: requestConfig) }.eraseToAnyPublisher()
        }
    }
}
