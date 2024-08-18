//
//  BaseNetworkClientTests.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import XCTest
import Combine
import DevToolsNetworking

final class BaseNetworkClientTests: XCTestCase {
    enum Constant {
        static let unAuthorizedCode = 401
        static let forbiddenCode = 403
        static let notFoundCode = 404
        static let successCode = 200
    }
    private var sut: BaseNetworkClient!
    private var mockNetworkDataProvider: MockNetworkDataProvider!
    private var mockDevNetworkRequestFactory: MockDevNetworkRequestFactory!
    private var cancelBag = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        mockNetworkDataProvider = MockNetworkDataProvider()
        mockDevNetworkRequestFactory = MockDevNetworkRequestFactory()
        sut = makeSUT()
    }

    private func makeSUT() -> BaseNetworkClient {
        BaseNetworkClient(
            dataProvider: mockNetworkDataProvider,
            requestFactory: mockDevNetworkRequestFactory
        )
    }
    
    func testExecuteGetRequestDecodeSuccess() throws {
        // Given
        let expectedResponseData = makeValidJSON().data(using: .unicode)!
        let requestConfig = MockDevRequestConfig.mock(method: .get)
        
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        
        mockNetworkDataProvider.mockOutput = .just(
            (
                data: expectedResponseData,
                response: HTTPURLResponse.mock(url: requestConfig.baseURL, statusCode: Constant.successCode) as URLResponse
            )
        )
        // Use an expectation to wait for the async operation to complete
        let expectation = expectation(description: "Awaiting publisher result")
        var receivedResult: Result<MockObjectDecoded, Error>? = nil
        
        // When
        let publisher: AnyPublisher<MockObjectDecoded, Error> = sut.execute(requestConfig)
        publisher.sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                receivedResult = .failure(error)
            }
            expectation.fulfill()
        } receiveValue: { decodedResult in
            receivedResult = .success(decodedResult)
        }
        .store(in: &cancelBag)
        
        // Then
        waitForExpectations(timeout: defaultTimeout)
        
        switch receivedResult {
        case .success(let decodedResult):
            XCTAssertEqual(decodedResult, try? JSONDecoder().decode(MockObjectDecoded.self, from: expectedResponseData))
        case .failure(let error):
            XCTFail("Unexpected error: \(error.localizedDescription)")
        case .none:
            XCTFail("No result received")
        }
    }

    
    func testExecuteGetRequestFailsDecodingError() throws {
        // Given
        let requestConfig = MockDevRequestConfig.mock(method: .get)
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        mockNetworkDataProvider.mockOutput = .just(
            (
                data: makeInValidJSON().data(using: .unicode)!,
                response: HTTPURLResponse.mock(url: requestConfig.baseURL) as URLResponse
            )
        )
        
        // When
        let publisher: AnyPublisher<MockObjectDecoded, Error> = sut.execute(requestConfig)
        _ = publisher.sink { completion in
            switch completion {
            case .finished:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error as? DevToolsNetworking.NetworkError, .unexpectedResponse)
            }
        } receiveValue: { _ in
            XCTFail()
        }
    }
    
    func testExecuteGetRequestFailsDecodingErrorl() throws {
        // Given
        let requestConfig = MockDevRequestConfig.mock(method: .get)
        
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        
        mockNetworkDataProvider.mockOutput = .just(
            (
                data: makeInValidJSON().data(using: .unicode)!,
                response: HTTPURLResponse.mock(url: requestConfig.baseURL) as URLResponse
            )
        )
        // Use an expectation to wait for the asynchronous operation to complete
        let expectation = expectation(description: "Awaiting publisher completion")
        var receivedResult: Result<MockObjectDecoded, Error>? = nil
        
        // When
        let publisher: AnyPublisher<MockObjectDecoded, Error> = sut.execute(requestConfig)
        publisher.sink { completion in
            switch completion {
            case .finished:
                break;
            case .failure(let error):
                receivedResult = .failure(error)
            }
            expectation.fulfill()
        } receiveValue: { value in
            receivedResult = .success(value)
        }
        .store(in: &cancelBag)
        
        // Then
        waitForExpectations(timeout: defaultTimeout)
        
        switch receivedResult {
        case .success:
            XCTFail("Expected failure, but received success.")
        case .failure(let error):
            XCTAssertEqual(error as? DevToolsNetworking.NetworkError, .unexpectedResponse)
        case .none:
            XCTFail("No result received from the publisher.")
        }
    }

    
    func testNetworkErrorReceivedForAllMethods() {
        DevHTTPMethod.allCases.forEach {
            runTestRequestFailsWithNetworkError(httpMethod: $0)
        }
    }
    
    func testUnexpectedStatusCodeReceivedForAllMethods() {
        DevHTTPMethod.allCases.forEach { httpMethod in
            [Constant.forbiddenCode, Constant.notFoundCode, Constant.unAuthorizedCode].forEach { code in
                runTestRequestFailsWithStatusCode(
                    requestConfig: MockDevRequestConfig.mock(method: httpMethod),
                    failStatusCode: code,
                    fetchedData: Data()
                )
            }
            
        }
    }
    
    func testReceivedCustomAPIMessageForAllMethods() {
        DevHTTPMethod.allCases.forEach { httpMethod in
            runTestRequestFailsWithStatusCode(
                requestConfig: MockDevRequestConfig.mock(method: httpMethod),
                failStatusCode: Constant.successCode,
                fetchedData: makeAPIErrorJSON().data(using: .unicode)!
            )
        }
    }
    
    private func runTestRequestFailsWithNetworkError(httpMethod: DevHTTPMethod) {
        runTestReachabilityError(requestConfig: MockDevRequestConfig.mock(method: httpMethod), urlError: URLError(.notConnectedToInternet))
        runTestReachabilityError(requestConfig: MockDevRequestConfig.mock(method: httpMethod), urlError: URLError(.networkConnectionLost))
        runTestReachabilityError(requestConfig: MockDevRequestConfig.mock(method: httpMethod), urlError: URLError(.dataNotAllowed))
        runTestReachabilityError(requestConfig: MockDevRequestConfig.mock(method: httpMethod), urlError: URLError(.internationalRoamingOff))
        runTestReachabilityError(requestConfig: MockDevRequestConfig.mock(method: httpMethod), urlError: URLError(.cannotConnectToHost))
        runTestReachabilityError(requestConfig: MockDevRequestConfig.mock(method: httpMethod), urlError: URLError(.timedOut))
        runTestReachabilityError(requestConfig: MockDevRequestConfig.mock(method: httpMethod), urlError: URLError(.secureConnectionFailed))
    }
    
    private func runTestReachabilityError(requestConfig: MockDevRequestConfig, urlError: URLError) {
        // Given
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        
        mockNetworkDataProvider.mockOutput = .fail(urlError)
        // Use an expectation to wait for the asynchronous operation to complete
        let expectation = expectation(description: "Awaiting reachability error result")
        var receivedResult: Result<MockObjectDecoded, Error>? = nil
        
        // When
        let publisher: AnyPublisher<MockObjectDecoded, Error> = sut.execute(requestConfig)
        publisher.sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                receivedResult = .failure(error)
            }
            expectation.fulfill()
        } receiveValue: { value in
            receivedResult = .success(value)
        }
        .store(in: &cancelBag)
        
        // Then
        waitForExpectations(timeout: defaultTimeout)
        
        switch receivedResult {
        case .success:
            XCTFail("Expected failure, but received success.")
        case .failure(let error):
            XCTAssertEqual(error as? DevToolsNetworking.NetworkError, DevToolsNetworking.NetworkError.reachability)
        case .none:
            XCTFail("No result received from the publisher.")
        }
    }

    
    private func runTestRequestFailsWithStatusCode(requestConfig: MockDevRequestConfig, failStatusCode: Int, fetchedData: Data) {
        // Given
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        mockNetworkDataProvider.mockOutput = .just(
            (
                data: fetchedData,
                response: HTTPURLResponse.mock(url: requestConfig.baseURL, statusCode: failStatusCode) as URLResponse
            )
        )
        
        // When
        let publisher: AnyPublisher<MockObjectDecoded, Error> = sut.execute(requestConfig)
        _ = publisher.sink { completion in
            switch completion {
            case .finished:
                XCTFail()
            case .failure(let receivedError):
                guard let networkError = receivedError as? DevToolsNetworking.NetworkError else {
                    XCTFail()
                    return
                }
                if failStatusCode == Constant.unAuthorizedCode {
                    XCTAssertEqual(networkError, DevToolsNetworking.NetworkError.unauthorized)
                } else if failStatusCode == Constant.forbiddenCode {
                    XCTAssertEqual(networkError, DevToolsNetworking.NetworkError.forbidden)
                } else if failStatusCode == Constant.notFoundCode {
                    XCTAssertEqual(networkError, DevToolsNetworking.NetworkError.resourceNotFound)
                } else {
                    let apiError = (try? JSONDecoder().decode(ApiErrorResponse.self, from: fetchedData)) ?? ApiErrorResponse(code: "", message: "")
                    XCTAssertEqual(networkError, NetworkError.apiErrorResponse(apiError))
                }
            }
        } receiveValue: { _ in
            XCTFail()
        }
    }
    
    private func runTestRequestFailsWithStatusCode2(requestConfig: MockDevRequestConfig, failStatusCode: Int, fetchedData: Data) {
        // Given
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        
        mockNetworkDataProvider.mockOutput = .just(
            (
                data: fetchedData,
                response: HTTPURLResponse.mock(url: requestConfig.baseURL, statusCode: failStatusCode) as URLResponse
            )
        )
        // Use an expectation to wait for the asynchronous operation to complete
        let expectation = self.expectation(description: "Awaiting request failure with status code")
        var receivedResult: Result<MockObjectDecoded, Error>? = nil

        // When
        let publisher: AnyPublisher<MockObjectDecoded, Error> = sut.execute(requestConfig)
        publisher.sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let receivedError):
                receivedResult = .failure(receivedError)
            }
            expectation.fulfill()
        } receiveValue: { value in
            receivedResult = .success(value)
        }
        .store(in: &cancelBag)
        
        // Then
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        
        switch receivedResult {
        case .success:
            XCTFail("Expected failure, but received success.")
        case .failure(let receivedError):
            guard let networkError = receivedError as? DevToolsNetworking.NetworkError else {
                XCTFail("Received error is not a NetworkError")
                return
            }
            
            switch failStatusCode {
            case Constant.unAuthorizedCode:
                XCTAssertEqual(networkError, DevToolsNetworking.NetworkError.unauthorized, "Expected unauthorized error")
            case Constant.forbiddenCode:
                XCTAssertEqual(networkError, DevToolsNetworking.NetworkError.forbidden, "Expected forbidden error")
            case Constant.notFoundCode:
                XCTAssertEqual(networkError, DevToolsNetworking.NetworkError.resourceNotFound, "Expected resource not found error")
            default:
                let apiError = (try? JSONDecoder().decode(ApiErrorResponse.self, from: fetchedData)) ?? ApiErrorResponse(code: "", message: "")
                XCTAssertEqual(networkError, NetworkError.apiErrorResponse(apiError), "Expected API error response")
            }
        case .none:
            XCTFail("No result received from the publisher.")
        }
    }

    
    private func makeAPIErrorJSON(code: String = "W123", message: String = "Upsie, API dead!") -> String {
            """
            {
                "code": "\(code)",
                "message": "\(message)",
            }
            """
    }
    
    private func makeValidJSON(value: String = "Hello world!") -> String {
            """
            {
                "mockProperty": "\(value)",
            }
            """
    }
    
    private func makeInValidJSON() -> String {
            """
            {invalid jsonasdasd ..das
            """
    }
}
