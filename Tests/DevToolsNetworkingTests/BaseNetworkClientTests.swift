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

    private var sut: BaseNetworkClient!
    private var mockNetworkDataProvider: MockNetworkDataProvider!
    private var mockDevNetworkRequestFactory: MockDevNetworkRequestFactory!
    private lazy var mockJSON = """
    {
        "message": "Hello World!"
    }
    """
    private lazy var mockedJSONData = mockJSON.data(using: .unicode)!
    private lazy var mockDecodedJSON = try! JSONDecoder().decode(MockJSONDecoded.self, from: mockedJSONData)
    private lazy var mockInvalidJSON = """
    {invalid jsonasdasd ..das
    """
    private lazy var mockedInvalidJSONData = mockInvalidJSON.data(using: .unicode)!
        
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
    
    func testExecuteGetRequestSuccess() throws {
        // Given
        let requestConfig = MockDevRequestConfig.mock(method: .get)
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        mockNetworkDataProvider.mockOutput = .just(
            (
                data: mockedJSONData,
                response: HTTPURLResponse.mock(url: requestConfig.baseURL) as URLResponse
            )
        )
        
        // When
        let publisher: AnyPublisher<MockJSONDecoded, Error> = sut.execute(requestConfig)
        _ = publisher.sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        } receiveValue: { decodedResult in
            XCTAssertEqual(decodedResult, self.mockDecodedJSON)
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
                data: mockedInvalidJSONData,
                response: HTTPURLResponse.mock(url: requestConfig.baseURL) as URLResponse
            )
        )
        
        // When
        let publisher: AnyPublisher<MockJSONDecoded, Error> = sut.execute(requestConfig)
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
    
    func testExecuteRequestFailsNetworkError() throws {
        testReachabilityError(urlError: URLError(.notConnectedToInternet))
        testReachabilityError(urlError: URLError(.networkConnectionLost))
        testReachabilityError(urlError: URLError(.dataNotAllowed))
        testReachabilityError(urlError: URLError(.internationalRoamingOff))
        testReachabilityError(urlError: URLError(.cannotConnectToHost))
        testReachabilityError(urlError: URLError(.timedOut))
        testReachabilityError(urlError: URLError(.secureConnectionFailed))
    }
    
    private func testReachabilityError(urlError: URLError) {
        // Given
        let requestConfig = MockDevRequestConfig.mock(method: .get)
        mockDevNetworkRequestFactory.mockRequest = URLRequest(url: URL(string: requestConfig.baseURL)!)
        mockDevNetworkRequestFactory.requestCalled = { calledConfig in
            XCTAssertEqual(calledConfig as! MockDevRequestConfig, requestConfig)
        }
        mockNetworkDataProvider.mockOutput = .fail(urlError)
        
        
        // When
        let publisher: AnyPublisher<MockJSONDecoded, Error> = sut.execute(requestConfig)
        _ = publisher.sink { completion in
            switch completion {
            case .finished:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error as? DevToolsNetworking.NetworkError, DevToolsNetworking.NetworkError.reachability)
            }
        } receiveValue: { _ in
            XCTFail()
        }
    }
}
