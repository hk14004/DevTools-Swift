//
//  Logger.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 09/06/2025.
//

import OSLog

public extension Logger {
    static let network = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DevNetwork",
        category: "network"
    )
}

public extension Logger {
    static func logRequest(_ request: URLRequest) {
        network.info(
            """
            ----------DevNetworkRequestPrepared--------------
            Request
            URL: \(request.url?.absoluteString ?? "<nil>")
            Method: \(request.httpMethod ?? "<nil>")
            Headers: 
            ---
            \(formattedHeaders(request.allHTTPHeaderFields))
            ---
            Body: 
            \(prettyPrintedJSON(request.httpBody))
            """
        )
    }
    
    static func logResponse(_ response: URLSession.DataTaskPublisher.Output) {
        Logger.network.info(
            """
            ----------DevNetworkResponseReceived----------
            Response
            Status Code: \((response.response as? HTTPURLResponse)?.statusCode ?? 0)
            Headers: 
            ---
            \(formattedHeaders((response.response as? HTTPURLResponse)?.allHeaderFields as? [String: Any]))
            ---
            Body: 
            \(prettyPrintedJSON(response.data))
            """
        )
    }
    
    static func logNoResponse(error: Error) {
        Logger.network.info(
            """
            ----------DevNetworkNoResponse----------
            \(error)
            """
        )
    }
    
    static private func formattedHeaders(_ headers: [String: Any]?) -> String {
        guard let headers = headers, !headers.isEmpty else { return "<nil>" }
        return headers.map { "\($0): \($1)" }.joined(separator: "\n")
    }
    
    static private func prettyPrintedJSON(_ data: Data?) -> String {
        guard let data = data else { return "<nil>" }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return String(data: data, encoding: .utf8) ?? "<non-utf8 body> - \(data.count) bytes"
    }
}
