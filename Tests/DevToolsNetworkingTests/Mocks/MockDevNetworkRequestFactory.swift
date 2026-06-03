//
//  MockDevNetworkRequestFactory.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import Foundation
import DevToolsNetworking

class MockDevNetworkRequestFactory: DevNetworkRequestFactory {
    
    var mockRequest: URLRequest!
    var requestCalled: ((DevRequestConfig)->())?
    
    public func urlRequest(requestConfig: DevRequestConfig) throws -> URLRequest {
        requestCalled?(requestConfig)
        return mockRequest
    }
}
