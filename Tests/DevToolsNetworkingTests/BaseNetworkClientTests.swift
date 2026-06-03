import XCTest
import Combine
import DevToolsNetworking

final class BaseNetworkClientTests: XCTestCase {

    // MARK: - Constants
    enum Constant {
        static let unauthorizedCode = 401
        static let forbiddenCode = 403
        static let notFoundCode = 404
        static let successCode = 200
    }

    // MARK: - Properties
    private var sut: BaseNetworkClient!
    private var mockNetworkDataProvider: MockNetworkDataProvider!
    private var mockDevNetworkRequestFactory: MockDevNetworkRequestFactory!
    private var mockNetworkReachability: MockNetworkReachability!
    private var cancelBag = Set<AnyCancellable>()

    // MARK: - Setup
    override func setUpWithError() throws {
        mockNetworkDataProvider = MockNetworkDataProvider()
        mockDevNetworkRequestFactory = MockDevNetworkRequestFactory()
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: "http://mock.com")!)
        mockNetworkReachability = MockNetworkReachability(isReachable: true)
        sut = makeSUT()
    }

    private func makeSUT(plugins: [any NetworkClientPlugin] = []) -> BaseNetworkClient {
        BaseNetworkClient(
            dataProvider: mockNetworkDataProvider,
            requestFactory: mockDevNetworkRequestFactory,
            reachabilityNotifier: mockNetworkReachability,
            plugins: plugins
        )
    }

    // MARK: - Decode success

    func testExecuteDecodeSuccess() {
        let expectedData = makeValidJSON().data(using: .unicode)!
        let config = MockDevRequestConfig.mock(method: .get)
        mockNetworkDataProvider.mockOutput = .just((
            data: expectedData,
            response: HTTPURLResponse.mock(url: config.baseURL, statusCode: Constant.successCode) as URLResponse
        ))

        let result: Result<MockObjectDecoded, Error>? = execute(config)

        switch result {
        case .success(let decoded):
            XCTAssertEqual(decoded, try? JSONDecoder().decode(MockObjectDecoded.self, from: expectedData))
        default:
            XCTFail("Expected success, got \(String(describing: result))")
        }
    }

    // MARK: - Decode failure

    func testExecuteFailsOnInvalidJSON() {
        let config = MockDevRequestConfig.mock(method: .get)
        mockNetworkDataProvider.mockOutput = .just((
            data: makeInvalidJSON().data(using: .unicode)!,
            response: HTTPURLResponse.mock(url: config.baseURL, statusCode: Constant.successCode) as URLResponse
        ))

        let result: Result<MockObjectDecoded, Error>? = execute(config)

        assertNetworkError(result, equals: .unexpectedResponse)
    }

    // MARK: - Status codes

    func testNetworkErrorReceivedForAllMethods() {
        DevHTTPMethod.allCases.forEach { runReachabilityErrors(method: $0) }
    }

    func testUnexpectedStatusCodesForAllMethods() {
        DevHTTPMethod.allCases.forEach { method in
            [Constant.forbiddenCode, Constant.notFoundCode, Constant.unauthorizedCode].forEach { code in
                runStatusCodeFailure(method: method, statusCode: code, data: Data())
            }
        }
    }

    func testAPIErrorBodyDecodedForAllMethods() {
        DevHTTPMethod.allCases.forEach { method in
            runStatusCodeFailure(
                method: method,
                statusCode: Constant.successCode,
                data: makeAPIErrorJSON().data(using: .unicode)!
            )
        }
    }

    // MARK: - Plugin: willSend

    func testPluginWillSendIsCalledOnRequest() {
        let plugin = MockNetworkPlugin()
        sut = makeSUT(plugins: [plugin])
        mockNetworkDataProvider.mockOutput = successOutput()

        let _: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: .get))

        XCTAssertEqual(plugin.willSendCallCount, 1)
    }

    // MARK: - Plugin: didReceive

    func testPluginDidReceiveIsCalledWithSuccessOnSuccessfulRequest() {
        let plugin = MockNetworkPlugin()
        sut = makeSUT(plugins: [plugin])
        mockNetworkDataProvider.mockOutput = successOutput()

        let _: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: .get))

        XCTAssertEqual(plugin.didReceiveCallCount, 1)
        guard case .success = plugin.lastDidReceiveResult else {
            XCTFail("Expected didReceive to be called with success result")
            return
        }
    }

    func testPluginDidReceiveIsCalledWithFailureOnNetworkError() {
        let plugin = MockNetworkPlugin()
        sut = makeSUT(plugins: [plugin])
        mockNetworkDataProvider.mockOutput = .fail(URLError(.notConnectedToInternet))

        let _: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: .get))

        XCTAssertEqual(plugin.didReceiveCallCount, 1)
        guard case .failure = plugin.lastDidReceiveResult else {
            XCTFail("Expected didReceive to be called with failure result")
            return
        }
    }

    // MARK: - Plugin: process

    func testPluginProcessCanTransformSuccessToFailure() {
        let plugin = MockNetworkPlugin()
        plugin.processModifier = { _ in .failure(NetworkError.maintenance) }
        sut = makeSUT(plugins: [plugin])
        mockNetworkDataProvider.mockOutput = successOutput()

        let result: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: .get))

        assertNetworkError(result, equals: .maintenance)
        XCTAssertEqual(plugin.processCallCount, 1)
    }

    // MARK: - Plugin: prepare

    func testPluginPrepareCanModifyRequest() {
        let plugin = MockNetworkPlugin()
        plugin.prepareModifier = { request in
            var modified = request
            modified.setValue("test-token", forHTTPHeaderField: "Authorization")
            return modified
        }
        sut = makeSUT(plugins: [plugin])
        mockNetworkDataProvider.mockOutput = successOutput()

        let _: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: .get))

        XCTAssertEqual(plugin.prepareCallCount, 1)
        XCTAssertEqual(mockNetworkDataProvider.receivedRequest?.value(forHTTPHeaderField: "Authorization"), "test-token")
    }

    // MARK: - Plugin: chaining

    func testMultiplePluginsAreAllCalled() {
        let plugin1 = MockNetworkPlugin()
        let plugin2 = MockNetworkPlugin()
        sut = makeSUT(plugins: [plugin1, plugin2])
        mockNetworkDataProvider.mockOutput = successOutput()

        let _: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: .get))

        XCTAssertEqual(plugin1.willSendCallCount, 1)
        XCTAssertEqual(plugin2.willSendCallCount, 1)
        XCTAssertEqual(plugin1.didReceiveCallCount, 1)
        XCTAssertEqual(plugin2.didReceiveCallCount, 1)
    }
}

// MARK: - Private helpers

private extension BaseNetworkClientTests {

    /// Executes a request and waits for the result, returning it synchronously via expectation.
    @discardableResult
    func execute<T: Codable>(_ config: DevRequestConfig) -> Result<T, Error>? {
        let expectation = expectation(description: "Request completes")
        var result: Result<T, Error>?

        let publisher: AnyPublisher<T, Error> = sut.execute(config)
        publisher
            .sink { completion in
                if case .failure(let error) = completion { result = .failure(error) }
                expectation.fulfill()
            } receiveValue: { value in
                result = .success(value)
            }
            .store(in: &cancelBag)

        waitForExpectations(timeout: defaultTimeout)
        return result
    }

    func assertNetworkError(_ result: Result<MockObjectDecoded, Error>?, equals expected: NetworkError) {
        guard case .failure(let error) = result else {
            XCTFail("Expected failure, got \(String(describing: result))")
            return
        }
        XCTAssertEqual(error as? NetworkError, expected)
    }

    func successOutput(value: String = "Hello world!") -> AnyPublisher<DevNetworkDataProvider.Output, URLError> {
        .just((
            data: makeValidJSON(value: value).data(using: .unicode)!,
            response: HTTPURLResponse.mock(url: "http://mock.com", statusCode: Constant.successCode) as URLResponse
        ))
    }

    func runReachabilityErrors(method: DevHTTPMethod) {
        let errors: [URLError] = [
            URLError(.notConnectedToInternet), URLError(.networkConnectionLost),
            URLError(.dataNotAllowed), URLError(.internationalRoamingOff),
            URLError(.cannotConnectToHost), URLError(.timedOut),
            URLError(.secureConnectionFailed)
        ]
        errors.forEach { urlError in
            mockNetworkDataProvider.mockOutput = .fail(urlError)
            let result: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: method))
            assertNetworkError(result, equals: .reachability)
        }
    }

    func runStatusCodeFailure(method: DevHTTPMethod, statusCode: Int, data: Data) {
        mockNetworkDataProvider.mockOutput = .just((
            data: data,
            response: HTTPURLResponse.mock(url: "http://mock.com", statusCode: statusCode) as URLResponse
        ))

        let result: Result<MockObjectDecoded, Error>? = execute(MockDevRequestConfig.mock(method: method))

        guard case .failure(let error) = result, let networkError = error as? NetworkError else {
            XCTFail("Expected NetworkError failure for status \(statusCode)")
            return
        }

        switch statusCode {
        case Constant.unauthorizedCode:
            XCTAssertEqual(networkError, .unauthorized)
        case Constant.forbiddenCode:
            XCTAssertEqual(networkError, .forbidden)
        case Constant.notFoundCode:
            XCTAssertEqual(networkError, .resourceNotFound)
        default:
            let expected = (try? JSONDecoder().decode(ApiErrorResponse.self, from: data))
                .map { NetworkError.apiErrorResponse($0) } ?? .unexpectedResponse
            XCTAssertEqual(networkError, expected)
        }
    }

    func makeAPIErrorJSON(code: String = "W123", message: String = "Upsie, API dead!") -> String {
        """
        {
            "code": "\(code)",
            "message": "\(message)"
        }
        """
    }

    func makeValidJSON(value: String = "Hello world!") -> String {
        """
        {
            "mockProperty": "\(value)"
        }
        """
    }

    func makeInvalidJSON() -> String {
        "{invalid json"
    }
}
