//
//  MockNetworkDataProvider.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import Foundation
import DevToolsNetworking

struct MockDevRequestConfig: DevRequestConfig, Equatable {
    var baseURL: String
    var path: String
    var method: DevHTTPMethod
    var queryItems: [URLQueryItem]?
    var bodyParameters: Data?
    var headers: [String : String]?
    var requiresAuthorization: Bool
    var timeoutInterval: TimeInterval
}

extension MockDevRequestConfig {
    static func mock(
        baseURL: String = "www.mock.com",
        path: String = "/mock",
        method: DevHTTPMethod,
        queryItems: [URLQueryItem]? = [
            URLQueryItem(name: "mock1", value: "mock1Value"),
            URLQueryItem(name: "mock2", value: "mock2Value")
        ],
        bodyParameters: Data? = nil,
        headers: [String : String]? = nil,
        requiresAuthorization: Bool = false,
        timeoutInterval: TimeInterval = 0
    ) -> MockDevRequestConfig {
        MockDevRequestConfig(
            baseURL: baseURL,
            path: path,
            method: method,
            queryItems: queryItems,
            bodyParameters: bodyParameters,
            headers: headers,
            requiresAuthorization: requiresAuthorization,
            timeoutInterval: timeoutInterval
        )
    }
}
