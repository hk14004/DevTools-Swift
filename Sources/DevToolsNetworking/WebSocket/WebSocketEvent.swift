import Foundation

/// Events emitted by a live WebSocket connection.
public enum WebSocketEvent {
    /// The connection handshake completed successfully. The socket is ready to send and receive.
    case connected
    /// A text or binary frame was received from the server.
    case message(WebSocketMessage)
    /// The connection closed. Emitted for both clean server-initiated closes and local `disconnect()` calls.
    /// After this event the `events` publisher completes with `.finished`.
    case disconnected(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}
