import Foundation

public protocol RequestConfig {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var bodyParameters: Data? { get }
    var headers: [String: String]? { get }
    var shouldAddAuthorizationHeader: Bool { get }
    var shouldAddSCAAuthentication: Bool { get }
    var timeoutInterval: TimeInterval { get }
}

public extension RequestConfig {
    var queryItems: [URLQueryItem]? { nil }
    var bodyParameters: Data? { nil }
    var headers: [String: String]? { nil }
    var timeoutInterval: TimeInterval { 60 }
}
