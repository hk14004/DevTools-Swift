import XCTest
import Combine
import DevToolsNetworking

final class BaseNetworkRequestFactoryTests: XCTestCase {
    private var sut: BaseNetworkRequestFactory!

    override func setUpWithError() throws {
        sut = BaseNetworkRequestFactory()
    }

    func testRequestIsCreatedWithConfig() throws {
        try DevHTTPMethod.allCases.forEach { method in
            try runTestUrlRequestCreation(
                config: MockDevRequestConfig.mock(
                    method: method,
                    bodyParameters: makeValidJSON().data(using: .unicode),
                    headers: ["key": "value"],
                    requiresAuthorization: false,
                    timeoutInterval: 69
                )
            )
        }
    }

    func testInvalidURLThrows() {
        let config = MockDevRequestConfig.mock(
            baseURL: "",
            method: .get
        )
        XCTAssertThrowsError(try sut.urlRequest(requestConfig: config)) { error in
            XCTAssertTrue(error is NetworkRequestFactoryError)
        }
    }

    // MARK: - Helpers

    private func runTestUrlRequestCreation(config: DevRequestConfig) throws {
        let request = try sut.urlRequest(requestConfig: config)

        XCTAssertEqual(request.timeoutInterval, config.timeoutInterval)
        XCTAssertEqual(request.url, URL(
            base: config.baseURL,
            path: config.path.urlEncoded ?? "",
            queryItems: config.queryItems
        ))
        XCTAssertEqual(request.httpMethod, config.method.rawValue)
        // mandatoryHeaders() returns [:] by default; only config headers expected
        XCTAssertEqual(request.allHTTPHeaderFields, config.headers)
        XCTAssertEqual(request.httpBody, config.bodyParameters)
    }

    private func makeValidJSON(value: String = "Hello world!") -> String {
        """
        {
            "mockProperty": "\(value)",
        }
        """
    }
}
