import Combine
import Foundation

public typealias NetworkResponse = URLSession.DataTaskPublisher.Output

/// A plugin receives callbacks at each stage of a request's lifecycle and can
/// modify the request or response, or perform side-effects such as logging.
///
/// All methods have default no-op implementations — only override what you need.
public protocol NetworkClientPlugin: AnyObject {

    /// Called after the request is built. Can modify it asynchronously (e.g. inject auth headers).
    func prepare(_ request: URLRequest, config: DevRequestConfig) -> AnyPublisher<URLRequest, Error>

    /// Called just before the request hits the network. Use for side-effects only (logging, analytics).
    func willSend(_ request: URLRequest, config: DevRequestConfig)

    /// Called after a response (or error) is received. Use for side-effects only (logging, analytics).
    func didReceive(_ result: Result<NetworkResponse, Error>, config: DevRequestConfig)

    /// Called before decoding. Can transform the result (e.g. map a 503 to a maintenance error).
    func process(_ result: Result<NetworkResponse, Error>, config: DevRequestConfig) -> Result<NetworkResponse, Error>
}

public extension NetworkClientPlugin {
    func prepare(_ request: URLRequest, config: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        .just(request)
    }
    func willSend(_ request: URLRequest, config: DevRequestConfig) {}
    func didReceive(_ result: Result<NetworkResponse, Error>, config: DevRequestConfig) {}
    func process(_ result: Result<NetworkResponse, Error>, config: DevRequestConfig) -> Result<NetworkResponse, Error> { result }
}
