import Combine
import Foundation

public protocol DatataskPublisher {
    func dataTaskPublisher(request: URLRequest) -> AnyPublisher<Data, Error>
}

extension URLSession: DatataskPublisher {
    public func dataTaskPublisher(request: URLRequest) -> AnyPublisher<Data, Error> {
        self.dataTaskPublisher(for: request)
            .tryMap { data in
                do {
                    guard
                        let response = data.response as? HTTPURLResponse,
                        200..<300 ~= response.statusCode
                    else {
                        throw NetworkError.unexpectedResponse
                    }
                    return data.data
                } catch {
                    throw error
                }
            }
            .eraseToAnyPublisher()
    }
}
