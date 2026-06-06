import Combine
import DevToolsNetworking

class MockAuthorizationHeaderProvider: DevAuthorizationHeaderProvider {
    var headersToReturn: [String: String]? = ["Authorization": "Bearer mock-token"]
    var errorToReturn: Error?

    func getAuthorizationHeaders() -> AnyPublisher<[String: String]?, Error> {
        if let error = errorToReturn {
            return .fail(error)
        }
        return .just(headersToReturn)
    }
}
