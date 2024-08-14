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
    var authType: DevRequestAuthType
    var timeoutInterval: TimeInterval
}

extension MockDevRequestConfig {
    static func mock(
        baseURL: String = "www.mock.com",
        path: String = "/mock",
        method: DevHTTPMethod,
        authType: DevRequestAuthType = .none,
        timeoutInterval: TimeInterval = 0
    ) -> MockDevRequestConfig {
        MockDevRequestConfig(
            baseURL: baseURL,
            path: path,
            method: method,
            authType: authType,
            timeoutInterval: timeoutInterval
        )
    }
}
