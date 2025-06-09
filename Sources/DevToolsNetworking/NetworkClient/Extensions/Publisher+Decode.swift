import Combine
import Foundation
import OSLog

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    // swiftlint:disable:next function_default_parameter_at_end
    func decode<T>(
        as type: T.Type = T.self,
        when request: URLRequest
    ) -> AnyPublisher<T, Error> where T: Codable {
        tryMap { data -> T in
            do {
                logRequest(request)
                logResponse(data)
                guard
                    let response = data.response as? HTTPURLResponse,
                    200..<300 ~= response.statusCode
                else {
                    throw networkError(data: data.data, response: data.response)
                }
                return try JSONDecoder().decode(T.self, from: data.data)
            } catch {
                throw networkError(data: data.data, response: data.response)
            }
        }
        .mapError { error -> Error in
            mapError(error)
        }
        .eraseToAnyPublisher()
    }
    
    private func mapError(_ error: Error) -> Error {
        if error is NetworkError {
            return error
        }
        if error.isReachabilityError {
            return NetworkError.reachability
        }
        return NetworkError.unexpected(error.localizedDescription)
    }
    
    private func networkError(
        data: Data,
        response: URLResponse
    ) -> NetworkError {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .resourceNotFound
        default:
            do {
                let apiError = try JSONDecoder().decode(ApiErrorResponse.self, from: data)
                return .apiErrorResponse(apiError)
            } catch {
                return .unexpectedResponse
            }
        }
    }
    
    // MARK: - Log
    
    private func logRequest(_ request: URLRequest) {
        Logger.network.info(
            """
            ----------DevNetworkRequestSent--------------
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
    
    private func logResponse(_ response: URLSession.DataTaskPublisher.Output) {
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
    
    private func formattedHeaders(_ headers: [String: Any]?) -> String {
        guard let headers = headers, !headers.isEmpty else { return "<nil>" }
        return headers.map { "\($0): \($1)" }.joined(separator: "\n")
    }
    
    private func prettyPrintedJSON(_ data: Data?) -> String {
        guard let data = data else { return "<nil>" }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return String(data: data, encoding: .utf8) ?? "<non-utf8 body> - \(data.count) bytes"
    }
}
