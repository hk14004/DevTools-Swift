//
//  BaseNetworkRequestFactoryTests.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import XCTest
import Combine
import DevToolsNetworking

final class BaseNetworkRequestFactoryTests: XCTestCase {
    private var sut: BaseNetworkRequestFactory!
    
    override func setUpWithError() throws {
        sut = makeSUT()
    }

    private func makeSUT() -> BaseNetworkRequestFactory {
        BaseNetworkRequestFactory()
    }
    
    func testRequestIsCreatedWithConfig() {
        DevHTTPMethod.allCases.forEach { method in
            runTestUrlRequestCreation(
                config: MockDevRequestConfig.mock(
                    method: method,
                    bodyParameters: makeValidJSON().data(using: .unicode),
                    headers: ["key" : "value"],
                    authType: .none,
                    timeoutInterval: 69
                )
            )
        }
    }
    
    private func runTestUrlRequestCreation(config: DevRequestConfig) {
        // Given
        
        // When
        let request = sut.urlRequest(requestConfig: config)
        
        // Then
        XCTAssertEqual(request.timeoutInterval, config.timeoutInterval)
        XCTAssertEqual(request.url, URL(
            base: config.baseURL,
            path: config.path.urlEncoded ?? "",
            queryItems: config.queryItems
        ))
        XCTAssertEqual(request.httpMethod, config.method.rawValue)
        
        var expectedHeaders = makeMandatoryHeaders()
        if let additionalHeaders = config.headers {
            expectedHeaders.merge(additionalHeaders, uniquingKeysWith: { _, new in new })
        }
        XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(request.httpBody, config.bodyParameters)
    }
    
    private func makeMandatoryHeaders() -> [String: String] {
        let osVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.releaseVersionNumber ?? ""
        let appBuildNumber = Bundle.main.buildVersionNumber ?? ""
        let deviceName = UIDevice.deviceName
        let deviceOS = "iOS"
        
        return [
            "App-Version": appVersion,
            "App-Build": appBuildNumber,
            "Device-OS": deviceOS,
            "Device-OS-Version": osVersion,
            "Device-Name": deviceName,
            "User-Agent": "App-(\(appVersion)/\(appBuildNumber))-(\(deviceOS)/\(osVersion))"
        ]
    }
    
    private func makeValidJSON(value: String = "Hello world!") -> String {
            """
            {
                "mockProperty": "\(value)",
            }
            """
    }
}
