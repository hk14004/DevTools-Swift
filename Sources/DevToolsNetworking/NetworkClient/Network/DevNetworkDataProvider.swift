import Combine
import Foundation

public protocol DevNetworkDataProvider {
    typealias Output = URLSession.DataTaskPublisher.Output

    func output(for request: URLRequest) -> AnyPublisher<Output, URLError>
}
