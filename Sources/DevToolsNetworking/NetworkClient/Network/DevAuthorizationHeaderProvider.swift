//
//  DevAuthorizationHeaderProvider.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 09/06/2025.
//

import Combine

public protocol DevAuthorizationHeaderProvider {
    func getAuthorizationHeaders() -> AnyPublisher<[String: String]?, Error>
}

public extension DevAuthorizationHeaderProvider {
    func makeBearerAuthHeader(token: String) -> [String: String] {
        ["Authorization" : "Bearer \(token)"]
    }
    
    func makeBasicAuthHeader(username: String, password: String) -> [String: String] {
        guard let basic = "\(username):\(password)".data(using: .utf8)?.base64EncodedString() else {
            return [:]
        }
        return ["Authorization" : "Basic \(basic)"]
    }
}

// MARK: Examples
private class BearerAuthorizationHeaderProvider: DevAuthorizationHeaderProvider {
    func getAuthorizationHeaders() -> AnyPublisher<[String: String]?, Error> {
        let fetchedToken = "123"
        return .just(makeBearerAuthHeader(token: fetchedToken))
    }
}

private class BasicAuthorizationHeaderProvider: DevAuthorizationHeaderProvider {
    func getAuthorizationHeaders() -> AnyPublisher<[String: String]?, Error> {
        let username = "test"
        let password = "test123"
        return .just(makeBasicAuthHeader(username: username, password: password))
    }
}
