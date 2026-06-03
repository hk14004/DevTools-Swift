import XCTest
import DevToolsNetworking

final class MaintenancePluginTests: XCTestCase {

    private let config = MockDevRequestConfig.mock(method: .get)

    // MARK: - Result passthrough

    func testProcessPassesThroughSuccessResponse() {
        let sut = MaintenancePlugin { _ in }

        let result = sut.process(makeSuccess(statusCode: 200), config: config)

        guard case .success = result else {
            XCTFail("Expected success to pass through")
            return
        }
    }

    func testProcessPassesThroughFailureResult() {
        let sut = MaintenancePlugin { _ in XCTFail("Callback should not fire for failures") }

        let result = sut.process(.failure(NetworkError.reachability), config: config)

        XCTAssertEqual(result.error as? NetworkError, .reachability)
    }

    // MARK: - Maintenance detection

    func testProcessReturnsMaintenanceErrorForDefaultStatusCode() {
        let sut = MaintenancePlugin { _ in }

        let result = sut.process(makeSuccess(statusCode: 503), config: config)

        XCTAssertEqual(result.error as? NetworkError, .maintenance)
    }

    func testProcessReturnsMaintenanceErrorForCustomStatusCode() {
        let sut = MaintenancePlugin(statusCode: 418) { _ in }

        let result = sut.process(makeSuccess(statusCode: 418), config: config)

        XCTAssertEqual(result.error as? NetworkError, .maintenance)
    }

    func testProcessDoesNotTriggerForOtherNonSuccessCodes() {
        var callbackFired = false
        let sut = MaintenancePlugin { _ in callbackFired = true }

        _ = sut.process(makeSuccess(statusCode: 500), config: config)

        XCTAssertFalse(callbackFired)
    }

    // MARK: - Callback transitions

    func testCallbackCalledWithTrueWhenMaintenanceBegins() {
        var received: [Bool] = []
        let sut = MaintenancePlugin { received.append($0) }

        _ = sut.process(makeSuccess(statusCode: 503), config: config)

        XCTAssertEqual(received, [true])
    }

    func testCallbackNotCalledAgainOnConsecutiveMaintenanceResponses() {
        var callCount = 0
        let sut = MaintenancePlugin { _ in callCount += 1 }

        _ = sut.process(makeSuccess(statusCode: 503), config: config)
        _ = sut.process(makeSuccess(statusCode: 503), config: config)

        XCTAssertEqual(callCount, 1)
    }

    func testCallbackCalledWithFalseWhenMaintenanceEnds() {
        var received: [Bool] = []
        let sut = MaintenancePlugin { received.append($0) }

        _ = sut.process(makeSuccess(statusCode: 503), config: config)
        _ = sut.process(makeSuccess(statusCode: 200), config: config)

        XCTAssertEqual(received, [true, false])
    }

    func testCallbackNotCalledIfNeverInMaintenance() {
        var callbackFired = false
        let sut = MaintenancePlugin { _ in callbackFired = true }

        _ = sut.process(makeSuccess(statusCode: 200), config: config)
        _ = sut.process(makeSuccess(statusCode: 200), config: config)

        XCTAssertFalse(callbackFired)
    }
}

// MARK: - Helpers

private extension MaintenancePluginTests {

    func makeSuccess(statusCode: Int) -> Result<NetworkResponse, Error> {
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return .success((data: Data(), response: response as URLResponse))
    }
}

private extension Result {
    var error: Failure? {
        guard case .failure(let e) = self else { return nil }
        return e
    }
}
