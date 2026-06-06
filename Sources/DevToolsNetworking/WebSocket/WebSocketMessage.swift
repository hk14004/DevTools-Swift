import Foundation

/// A message sent or received over a WebSocket connection.
public enum WebSocketMessage {
    /// A UTF-8 text frame.
    case text(String)
    /// A binary frame.
    case data(Data)
}
