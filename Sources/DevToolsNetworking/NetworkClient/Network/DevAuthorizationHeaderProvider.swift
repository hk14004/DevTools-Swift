import Combine

public protocol DevAuthorizationHeaderProvider {
    func getAuthorizationHeaders() -> AnyPublisher<[String: String]?, Error>
}

public extension DevAuthorizationHeaderProvider {
    func makeBearerAuthHeader(token: String) -> [String: String] {
        ["Authorization": "Bearer \(token)"]
    }

    func makeBasicAuthHeader(username: String, password: String) -> [String: String] {
        guard let encoded = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
            return [:]
        }
        return ["Authorization": "Basic \(encoded)"]
    }
}
