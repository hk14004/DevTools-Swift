import Combine
import Foundation

/// A network client that supports persistent WebSocket connections.
///
/// Extend `DevNetworkClient` with this protocol when a service needs real-time
/// bidirectional communication. `BaseNetworkClient` conforms to this out of the box.
///
/// ```swift
/// final class ChatService {
///     private let client: any DevWebSocketClient
///
///     init(client: any DevWebSocketClient) {
///         self.client = client
///     }
/// }
/// ```
public protocol DevWebSocketClient: DevNetworkClient {
    func connect(_ requestConfig: DevRequestConfig) -> AnyPublisher<WebSocketConnection, Error>
}
