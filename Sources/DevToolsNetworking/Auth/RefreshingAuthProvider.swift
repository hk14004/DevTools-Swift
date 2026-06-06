import Combine
import Foundation

// MARK: - TokenPair

/// A pair of access and refresh tokens returned from a token refresh call.
public struct TokenPair {
    public let accessToken: String
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

// MARK: - RefreshingAuthProvider

/// A `DevAuthorizationHeaderProvider` that proactively refreshes expired tokens
/// and deduplicates concurrent refresh calls.
///
/// When multiple requests arrive simultaneously with an expired token, only one
/// refresh call is made. All waiting requests share the result.
///
/// **Usage:**
/// ```swift
/// let provider = RefreshingAuthProvider(
///     getAccessToken:     { keychain.accessToken },
///     isAccessTokenValid: { keychain.isAccessTokenValid },
///     performRefresh:     { authService.refresh() },
///     storeTokens:        { keychain.store($0) },
///     onSessionExpired:   { coordinator.handleSessionExpired() }
/// )
///
/// let client = BaseNetworkClient(
///     ...,
///     plugins: [AuthPlugin(headerProvider: provider)]
/// )
/// ```
public final class RefreshingAuthProvider: DevAuthorizationHeaderProvider {

    // MARK: - Config

    private let getAccessToken: () -> String?
    private let isAccessTokenValid: () -> Bool
    private let performRefresh: () -> AnyPublisher<TokenPair, Error>
    private let storeTokens: (TokenPair) -> Void
    /// Called when the refresh token itself is expired. The returned publisher
    /// should emit once the user has re-authenticated (e.g. after showing the login screen).
    /// If `nil`, the `.sessionExpired` error is propagated immediately.
    private let onSessionExpired: (() -> AnyPublisher<Void, Never>)?

    // MARK: - Deduplication

    private var inProgressRefresh: AnyPublisher<String, Error>?
    private let queue = DispatchQueue(label: "DevToolsNetworking.RefreshingAuthProvider")

    // MARK: - Init

    /// - Parameters:
    ///   - getAccessToken: Returns the currently stored access token, or `nil` if none exists.
    ///   - isAccessTokenValid: Returns `true` if the stored access token can be used as-is.
    ///   - performRefresh: Makes the token refresh network call and returns a `TokenPair`.
    ///   - storeTokens: Persists the new token pair after a successful refresh.
    ///   - onSessionExpired: Called when the refresh itself fails (session fully expired).
    ///     Return a publisher that emits once the app has handled re-authentication.
    ///     If `nil`, `NetworkError.sessionExpired` is propagated immediately to the caller.
    public init(
        getAccessToken: @escaping () -> String?,
        isAccessTokenValid: @escaping () -> Bool,
        performRefresh: @escaping () -> AnyPublisher<TokenPair, Error>,
        storeTokens: @escaping (TokenPair) -> Void,
        onSessionExpired: (() -> AnyPublisher<Void, Never>)? = nil
    ) {
        self.getAccessToken = getAccessToken
        self.isAccessTokenValid = isAccessTokenValid
        self.performRefresh = performRefresh
        self.storeTokens = storeTokens
        self.onSessionExpired = onSessionExpired
    }

    // MARK: - DevAuthorizationHeaderProvider

    public func getAuthorizationHeaders() -> AnyPublisher<[String: String]?, Error> {
        guard let token = getAccessToken() else {
            return .fail(NetworkError.unauthorized)
        }
        if isAccessTokenValid() {
            return .just(makeBearerAuthHeader(token: token))
        }
        return refresh()
            .map { [weak self] newToken in self?.makeBearerAuthHeader(token: newToken) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension RefreshingAuthProvider {

    func refresh() -> AnyPublisher<String, Error> {
        queue.sync {
            if let running = inProgressRefresh { return running }

            var publisher: AnyPublisher<String, Error> = performRefresh()
                .handleEvents(
                    receiveOutput: { [weak self] pair in
                        self?.storeTokens(pair)
                    },
                    receiveCompletion: { [weak self] _ in
                        self?.queue.async { self?.inProgressRefresh = nil }
                    },
                    receiveCancel: { [weak self] in
                        self?.queue.async { self?.inProgressRefresh = nil }
                    }
                )
                .map { $0.accessToken }
                .mapError { error -> Error in
                    // Reachability errors propagate as-is so the caller can handle offline state.
                    // Everything else means the refresh token itself is invalid — session expired.
                    guard (error as? NetworkError) == .reachability else {
                        return NetworkError.sessionExpired
                    }
                    return error
                }
                .eraseToAnyPublisher()

            if let handler = onSessionExpired {
                publisher = publisher
                    .delay(
                        whenError: { ($0 as? NetworkError) == .sessionExpired },
                        until: Deferred { handler() }
                    )
                    .eraseToAnyPublisher()
            }

            let shared = publisher.share().eraseToAnyPublisher()
            inProgressRefresh = shared
            return shared
        }
    }
}
