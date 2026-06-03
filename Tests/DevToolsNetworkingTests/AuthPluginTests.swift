import XCTest
import Combine
import DevToolsNetworking

final class AuthPluginTests: XCTestCase {

    private var provider: MockAuthorizationHeaderProvider!
    private var sut: AuthPlugin!
    private var cancelBag = Set<AnyCancellable>()

    private let request = URLRequest(url: URL(string: "https://example.com")!)

    override func setUp() {
        provider = MockAuthorizationHeaderProvider()
        sut = AuthPlugin(headerProvider: provider)
    }

    // MARK: - Auth not required

    func testPrepareReturnsRequestUnchangedWhenAuthNotRequired() {
        let config = MockDevRequestConfig.mock(method: .get, requiresAuthorization: false)

        let result = prepare(request, config: config)

        XCTAssertEqual(result?.allHTTPHeaderFields, request.allHTTPHeaderFields)
    }

    func testPrepareDoesNotCallProviderWhenAuthNotRequired() {
        provider.errorToReturn = NetworkError.unauthorized // would fail if called
        let config = MockDevRequestConfig.mock(method: .get, requiresAuthorization: false)

        let result = prepare(request, config: config)

        XCTAssertNotNil(result, "Should succeed without calling provider")
    }

    // MARK: - Auth required

    func testPrepareInjectsHeadersWhenAuthRequired() {
        provider.headersToReturn = ["Authorization": "Bearer test-token"]
        let config = MockDevRequestConfig.mock(method: .get, requiresAuthorization: true)

        let result = prepare(request, config: config)

        XCTAssertEqual(result?.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
    }

    func testPrepareInjectsMultipleHeaders() {
        provider.headersToReturn = [
            "Authorization": "Bearer test-token",
            "X-User-ID": "123"
        ]
        let config = MockDevRequestConfig.mock(method: .get, requiresAuthorization: true)

        let result = prepare(request, config: config)

        XCTAssertEqual(result?.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
        XCTAssertEqual(result?.value(forHTTPHeaderField: "X-User-ID"), "123")
    }

    func testPreparePreservesExistingHeadersWhenInjectingAuth() {
        var existingRequest = request
        existingRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        provider.headersToReturn = ["Authorization": "Bearer token"]
        let config = MockDevRequestConfig.mock(method: .get, requiresAuthorization: true)

        let result = prepare(existingRequest, config: config)

        XCTAssertEqual(result?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(result?.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }

    func testPrepareDoesNotAddAuthHeaderWhenProviderReturnsNil() {
        provider.headersToReturn = nil
        let config = MockDevRequestConfig.mock(method: .get, requiresAuthorization: true)

        let result = prepare(request, config: config)

        XCTAssertNil(result?.value(forHTTPHeaderField: "Authorization"))
    }

    // MARK: - Provider error

    func testPrepareForwardsErrorFromProvider() {
        provider.errorToReturn = NetworkError.unauthorized
        let config = MockDevRequestConfig.mock(method: .get, requiresAuthorization: true)

        var receivedError: Error?
        sut.prepare(request, config: config)
            .sink { if case .failure(let e) = $0 { receivedError = e } } receiveValue: { _ in }
            .store(in: &cancelBag)

        XCTAssertEqual(receivedError as? NetworkError, .unauthorized)
    }
}

// MARK: - Helpers

private extension AuthPluginTests {
    /// Synchronously runs prepare (works because mock publisher is synchronous).
    func prepare(_ request: URLRequest, config: DevRequestConfig) -> URLRequest? {
        var result: URLRequest?
        sut.prepare(request, config: config)
            .sink { _ in } receiveValue: { result = $0 }
            .store(in: &cancelBag)
        return result
    }
}
