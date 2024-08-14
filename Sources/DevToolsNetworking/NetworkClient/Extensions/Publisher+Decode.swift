import Combine
import Foundation

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    private var logSeparator: String { "----------------------------------------------------" }
    
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
        print(logSeparator)
        print("Request - URL: \(request.url?.absoluteString ?? "<nil>")")
        print("Request - Headers: \(request.allHTTPHeaderFields ?? [:])")
        let body = request.httpBody.map { String(data: $0, encoding: .utf8) ?? "<nil>" }
        print("Request - Body: \(body ?? "<nil>")")
        print(logSeparator)
    }
    
    private func logResponse(_ response: URLSession.DataTaskPublisher.Output) {
        print("Response - Status Code: \((response.response as? HTTPURLResponse)?.statusCode ?? 0)")
        print("Response - \(String(data: response.data, encoding: .utf8) ?? "<nil>")")
        print(logSeparator)
    }
}
