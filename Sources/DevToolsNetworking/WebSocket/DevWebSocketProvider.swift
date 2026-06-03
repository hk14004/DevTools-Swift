import Foundation

/// An opt-in capability for data providers that support WebSocket connections.
///
/// `DefaultNetworkDataProvider` conforms to this protocol out of the box.
/// If you implement your own `DevNetworkDataProvider`, adopt this protocol too
/// to unlock `BaseNetworkClient.connect(_:)`.
///
/// The `request` is prepared by `BaseNetworkClient` through the normal plugin pipeline
/// (auth headers, logging, etc.) before being forwarded here.
public protocol DevWebSocketProvider {
    func connect(request: URLRequest) -> WebSocketConnection
}
