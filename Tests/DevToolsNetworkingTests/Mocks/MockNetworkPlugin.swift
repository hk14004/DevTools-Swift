import Foundation
import Combine
import DevToolsNetworking

class MockNetworkPlugin: NetworkClientPlugin {

    // MARK: - Call counts
    var prepareCallCount = 0
    var willSendCallCount = 0
    var didReceiveCallCount = 0
    var processCallCount = 0

    // MARK: - Captured values
    var lastWillSendRequest: URLRequest?
    var lastDidReceiveResult: Result<NetworkResponse, Error>?

    // MARK: - Overridable behaviour
    var prepareModifier: ((URLRequest) -> URLRequest)?
    var processModifier: ((Result<NetworkResponse, Error>) -> Result<NetworkResponse, Error>)?

    // MARK: - NetworkClientPlugin
    func prepare(_ request: URLRequest, config: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        prepareCallCount += 1
        return .just(prepareModifier?(request) ?? request)
    }

    func willSend(_ request: URLRequest, config: DevRequestConfig) {
        willSendCallCount += 1
        lastWillSendRequest = request
    }

    func didReceive(_ result: Result<NetworkResponse, Error>, config: DevRequestConfig) {
        didReceiveCallCount += 1
        lastDidReceiveResult = result
    }

    func process(_ result: Result<NetworkResponse, Error>, config: DevRequestConfig) -> Result<NetworkResponse, Error> {
        processCallCount += 1
        return processModifier?(result) ?? result
    }
}
