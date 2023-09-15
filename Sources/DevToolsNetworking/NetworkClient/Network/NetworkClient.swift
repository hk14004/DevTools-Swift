import Combine
import Foundation

public protocol NetworkClient: AnyObject {
    func execute<T: NetworkResponse>(_ requestConfig: RequestConfig) -> AnyPublisher<T, Error>
    func execute<T: NetworkResponse>(_ requestConfig: RequestConfig) -> AnyPublisher<[T], Error>
}
