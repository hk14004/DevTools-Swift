import Combine
import UIKit

extension String {
    public var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

public protocol NetworkRequestFactory {
    func urlRequest(
        requestConfig: RequestConfig,
        accessToken: String?
    ) -> URLRequest
}

//final class DefaultNetworkRequestFactory: NetworkRequestFactory {
//    // MARK: - Variables
//    private let networkConfig: NetworkConfig
//    private let appVersion = ""//Bundle.main.releaseVersionNumber ?? "0"
//    private let appBuildNumber = ""//Bundle.main.buildVersionNumberString
//    private let osVersionNumber = UIDevice.current.systemVersion
//    private let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
//    private var userAgentHeader: String { "SEB-(\(appVersion)/\(appBuildNumber))-(iOS/\(osVersion))" }
//
//    // MARK: - Methods
//    public init(networkConfig: NetworkConfig) {
//        self.networkConfig = networkConfig
//    }
//
//    public func urlRequest(
//        requestConfig: RequestConfig,
//        accessToken: String?
//    ) -> URLRequest {
//        let url = URL(
//            base: networkConfig.endpoint,
//            path: requestConfig.path.urlEncoded ?? "",
//            queryItems: requestConfig.queryItems
//        )
//        var request = URLRequest(url: url, timeoutInterval: requestConfig.timeoutInterval)
//        request.httpMethod = requestConfig.method.rawValue
//        request.allHTTPHeaderFields = allHTTPHeaderFields(
//            requestConfig: requestConfig,
//            accessToken: accessToken
//        )
//        request.httpBody = requestConfig.bodyParameters
//        return request
//    }
//
//    private func allHTTPHeaderFields(
//        requestConfig: RequestConfig,
//        accessToken: String?
//    ) -> [String: String] {
//        var headers = [
//            "Cache-Control": "no-cache, no-store",
//            "Content-Type": "application/json",
//            "SEB-App-Build": appBuildNumber,
//            "SEB-App-OS": "ios",
//            "SEB-App-OS-Version": osVersionNumber,
//            "SEB-App-Version": appVersion,
//            "SEB-Device-Name": "",//UIDevice.deviceName,
//            "User-Agent": userAgentHeader,
//            "X-Device-Resolution": "\(Int(UIScreen.main.nativeBounds.width))x\(Int(UIScreen.main.nativeBounds.height))",
//            "X-Request-ID": UUID().uuidString
//        ]
//        if requestConfig.shouldAddAuthorizationHeader, let accessToken = accessToken {
//            headers["Bearer token"] = accessToken
//        }
//        if let additionalHeaders = requestConfig.headers {
//            headers.merge(additionalHeaders, uniquingKeysWith: { _, new in new })
//        }
//        return headers
//    }
//}
