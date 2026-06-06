import XCTest
import Combine
import DevToolsNetworking

final class RefreshingAuthProviderTests: XCTestCase {

    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Valid token

    func testReturnsHeadersImmediatelyWhenTokenIsValid() {
        let sut = makeSUT(accessToken: "valid-token", isValid: true)

        let result = getHeaders(from: sut)

        XCTAssertEqual(result, ["Authorization": "Bearer valid-token"])
    }

    func testDoesNotCallRefreshWhenTokenIsValid() {
        var refreshCalled = false
        let sut = makeSUT(accessToken: "valid-token", isValid: true) {
            refreshCalled = true
            return .just(TokenPair(accessToken: "new", refreshToken: "new-refresh"))
        }

        _ = getHeaders(from: sut)

        XCTAssertFalse(refreshCalled)
    }

    // MARK: - No token

    func testFailsWithUnauthorizedWhenNoTokenStored() {
        let sut = makeSUT(accessToken: nil, isValid: false)

        let error = getError(from: sut)

        XCTAssertEqual(error as? NetworkError, .unauthorized)
    }

    // MARK: - Expired token → refresh

    func testRefreshesAndReturnsNewHeadersWhenTokenExpired() {
        let sut = makeSUT(accessToken: "expired", isValid: false) {
            .just(TokenPair(accessToken: "fresh-token", refreshToken: "new-refresh"))
        }

        let result = getHeaders(from: sut)

        XCTAssertEqual(result, ["Authorization": "Bearer fresh-token"])
    }

    func testStoresNewTokensAfterSuccessfulRefresh() {
        var storedPair: TokenPair?
        let sut = makeSUT(accessToken: "expired", isValid: false, storeTokens: { storedPair = $0 }) {
            .just(TokenPair(accessToken: "new-access", refreshToken: "new-refresh"))
        }

        _ = getHeaders(from: sut)

        XCTAssertEqual(storedPair?.accessToken, "new-access")
        XCTAssertEqual(storedPair?.refreshToken, "new-refresh")
    }

    // MARK: - Deduplication

    func testDeduplicatesConcurrentRefreshCalls() {
        var refreshCallCount = 0
        let subject = PassthroughSubject<TokenPair, Error>()
        let sut = makeSUT(accessToken: "expired", isValid: false) {
            refreshCallCount += 1
            return subject.eraseToAnyPublisher()
        }

        var result1: [String: String]? = nil
        var result2: [String: String]? = nil

        sut.getAuthorizationHeaders()
            .sink { _ in } receiveValue: { result1 = $0 }
            .store(in: &cancelBag)

        sut.getAuthorizationHeaders()
            .sink { _ in } receiveValue: { result2 = $0 }
            .store(in: &cancelBag)

        subject.send(TokenPair(accessToken: "shared-token", refreshToken: "r"))
        subject.send(completion: .finished)

        XCTAssertEqual(refreshCallCount, 1, "Refresh should only be called once")
        XCTAssertEqual(result1, ["Authorization": "Bearer shared-token"])
        XCTAssertEqual(result2, ["Authorization": "Bearer shared-token"])
    }

    // MARK: - Refresh errors

    func testReachabilityErrorPropagatesImmediately() {
        let sut = makeSUT(accessToken: "expired", isValid: false) {
            .fail(NetworkError.reachability)
        }

        let error = getError(from: sut)

        XCTAssertEqual(error as? NetworkError, .reachability)
    }

    func testNonReachabilityRefreshFailureMapsToSessionExpired() {
        let sut = makeSUT(accessToken: "expired", isValid: false) {
            .fail(NetworkError.unauthorized)
        }

        let error = getError(from: sut)

        XCTAssertEqual(error as? NetworkError, .sessionExpired)
    }

    func testSessionExpiredErrorPropagatesImmediatelyWhenNoHandler() {
        let sut = makeSUT(accessToken: "expired", isValid: false, onSessionExpired: nil) {
            .fail(NetworkError.unauthorized)
        }

        let error = getError(from: sut)

        XCTAssertEqual(error as? NetworkError, .sessionExpired)
    }

    func testSessionExpiredErrorDelayedUntilHandlerEmits() {
        let sessionExpiredSubject = PassthroughSubject<Void, Never>()
        let sut = makeSUT(
            accessToken: "expired",
            isValid: false,
            onSessionExpired: { sessionExpiredSubject.eraseToAnyPublisher() }
        ) {
            .fail(NetworkError.unauthorized)
        }

        var receivedError: Error?
        let expectation = expectation(description: "Error received after session expired fires")

        sut.getAuthorizationHeaders()
            .sink { completion in
                if case .failure(let e) = completion {
                    receivedError = e
                    expectation.fulfill()
                }
            } receiveValue: { _ in }
            .store(in: &cancelBag)

        XCTAssertNil(receivedError, "Error should not arrive before handler fires")

        sessionExpiredSubject.send(())

        waitForExpectations(timeout: defaultTimeout)
        XCTAssertEqual(receivedError as? NetworkError, .sessionExpired)
    }
}

// MARK: - Helpers

private extension RefreshingAuthProviderTests {

    func makeSUT(
        accessToken: String?,
        isValid: Bool,
        storeTokens: @escaping (TokenPair) -> Void = { _ in },
        onSessionExpired: (() -> AnyPublisher<Void, Never>)? = nil,
        performRefresh: @escaping () -> AnyPublisher<TokenPair, Error> = {
            .fail(NetworkError.unexpected("Not configured"))
        }
    ) -> RefreshingAuthProvider {
        RefreshingAuthProvider(
            getAccessToken: { accessToken },
            isAccessTokenValid: { isValid },
            performRefresh: performRefresh,
            storeTokens: storeTokens,
            onSessionExpired: onSessionExpired
        )
    }

    func getHeaders(from provider: RefreshingAuthProvider) -> [String: String]? {
        var result: [String: String]? = nil
        provider.getAuthorizationHeaders()
            .sink { _ in } receiveValue: { result = $0 }
            .store(in: &cancelBag)
        return result
    }

    func getError(from provider: RefreshingAuthProvider) -> Error? {
        var error: Error?
        provider.getAuthorizationHeaders()
            .sink { if case .failure(let e) = $0 { error = e } } receiveValue: { _ in }
            .store(in: &cancelBag)
        return error
    }
}
