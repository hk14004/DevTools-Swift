//
//  MockNetworkDataProvider.swift
//  
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import Foundation
import Combine
import DevToolsNetworking

class MockNetworkDataProvider: NSObject, DevNetworkDataProvider, URLSessionDelegate {

    var mockOutput: AnyPublisher<DevNetworkDataProvider.Output, URLError>!
    var receivedRequest: URLRequest?

    public func output(for request: URLRequest) -> AnyPublisher<Output, URLError> {
        receivedRequest = request
        return mockOutput
    }
}
