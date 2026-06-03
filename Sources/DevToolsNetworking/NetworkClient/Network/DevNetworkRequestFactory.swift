import Combine
import DevToolsCore

public enum NetworkRequestFactoryError: Error {
    case invalidURL(baseURL: String, path: String)
}

public protocol DevNetworkRequestFactory {
    func urlRequest(requestConfig: DevRequestConfig) throws -> URLRequest
}

open class BaseNetworkRequestFactory: DevNetworkRequestFactory {
    
    public init() {}
    
    public func urlRequest(requestConfig: DevRequestConfig) throws -> URLRequest {
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
        var headers = mandatoryHeaders()
        if let additionalHeaders = requestConfig.headers {
            headers.merge(additionalHeaders, uniquingKeysWith: { _, new in new })
        }
        request.allHTTPHeaderFields = headers
        request.httpBody = requestConfig.bodyParameters
        return request
    }
    
    /// Override in a subclass to inject app-wide headers into every request
    /// (e.g. device info, app version, custom User-Agent).
    ///
    /// Example:
    /// ```swift
    /// override func mandatoryHeaders() -> [String: String] {
    ///     let osVersion = UIDevice.current.systemVersion
    ///     let appVersion = Bundle.main.releaseVersionNumber ?? ""
    ///     let appBuildNumber = Bundle.main.buildVersionNumber ?? ""
    ///     let deviceName = UIDevice.deviceName
    ///     let deviceOS = "iOS"
    ///     return [
    ///         "App-Version": appVersion,
    ///         "App-Build": appBuildNumber,
    ///         "Device-OS": deviceOS,
    ///         "Device-OS-Version": osVersion,
    ///         "Device-Name": deviceName,
    ///         "User-Agent": "App-(\(appVersion)/\(appBuildNumber))-(\(deviceOS)/\(osVersion))"
    ///     ]
    /// }
    /// ```
    open func mandatoryHeaders() -> [String: String] { [:] }
}
