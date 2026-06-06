import Combine
import Foundation

/// A plugin that injects authorization headers into requests marked as requiring auth.
///
/// Provide a `DevAuthorizationHeaderProvider` to control how headers are fetched
/// (e.g. bearer token from keychain, basic auth credentials, custom scheme).
public final class AuthPlugin: NetworkClientPlugin {

    private let headerProvider: any DevAuthorizationHeaderProvider

    public init(headerProvider: any DevAuthorizationHeaderProvider) {
        self.headerProvider = headerProvider
    }

    public func prepare(_ request: URLRequest, config: DevRequestConfig) -> AnyPublisher<URLRequest, Error> {
        guard config.requiresAuthorization else {
            return .just(request)
        }
        return headerProvider.getAuthorizationHeaders()
            .map { headers -> URLRequest in
                var modified = request
                headers?.forEach { modified.setValue($1, forHTTPHeaderField: $0) }
                return modified
            }
            .eraseToAnyPublisher()
    }
}
