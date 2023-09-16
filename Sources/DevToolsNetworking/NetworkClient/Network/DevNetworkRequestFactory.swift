import Combine
import UIKit
import DevToolsCore

public protocol DevNetworkRequestFactory {
    func urlRequest(requestConfig: DevRequestConfig) -> URLRequest
}

open class BaseNetworkRequestFactory: DevNetworkRequestFactory {
    public func urlRequest(
        requestConfig: DevRequestConfig
    ) -> URLRequest {
        let url = URL(
            base: requestConfig.baseURL,
            path: requestConfig.path.urlEncoded ?? "",
            queryItems: requestConfig.queryItems
        )
        var request = URLRequest(url: url, timeoutInterval: requestConfig.timeoutInterval)
        request.httpMethod = requestConfig.method.rawValue
        var headers = makeMandatoryHeaders()
        if let additionalHeaders = requestConfig.headers {
            headers.merge(additionalHeaders, uniquingKeysWith: { _, new in new })
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
