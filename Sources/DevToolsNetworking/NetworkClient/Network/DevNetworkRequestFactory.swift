import Combine
import UIKit
import DevToolsCore

public enum NetworkRequestFactoryError: Error {
    case invalidURL(baseURL: String, path: String)
}

public protocol DevNetworkRequestFactory {
    func urlRequest(
        requestConfig: DevRequestConfig,
        authorizationHeaders: [String: String]?
    ) throws -> URLRequest
}

open class BaseNetworkRequestFactory: DevNetworkRequestFactory {
    
    public init() {}
    
    public func urlRequest(
        requestConfig: DevRequestConfig,
        authorizationHeaders: [String: String]?
    ) throws -> URLRequest {
        guard let url = URL(
            base: requestConfig.baseURL,
            path: requestConfig.path.urlEncoded ?? "",
            queryItems: requestConfig.queryItems
        ) else {
            throw NetworkRequestFactoryError.invalidURL(
                baseURL: requestConfig.baseURL,
                path: requestConfig.path
            )
        }
        var request = URLRequest(url: url, timeoutInterval: requestConfig.timeoutInterval)
        request.httpMethod = requestConfig.method.rawValue
        var headers = makeMandatoryHeaders()
        if let additionalHeaders = requestConfig.headers {
            headers.merge(additionalHeaders, uniquingKeysWith: { _, new in new })
        }
        if let authorizationHeaders = authorizationHeaders, requestConfig.requiresAuthorization {
            headers.merge(authorizationHeaders, uniquingKeysWith: { _, new in new })
        }
        request.allHTTPHeaderFields = headers
        request.httpBody = requestConfig.bodyParameters
        return request
    }
    
    public func makeMandatoryHeaders() -> [String: String] {
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
}
