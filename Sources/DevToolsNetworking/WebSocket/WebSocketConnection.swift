import Combine
import Foundation

/// A live WebSocket session returned by `BaseNetworkClient.connect(_:)`.
///
/// Hold onto this object for the lifetime of the connection — releasing it closes the socket.
/// Subscribe to `events` to receive incoming frames, call `send(_:)` to push outgoing ones,
/// and call `disconnect()` to close gracefully.
///
/// ```swift
/// var connection: WebSocketConnection?
/// var cancellables = Set<AnyCancellable>()
///
/// client.connect(wsConfig)
///     .sink(
///         receiveCompletion: { _ in },
///         receiveValue: { [weak self] conn in
///             self?.connection = conn
///             conn.events
///                 .receive(on: DispatchQueue.main)
///                 .sink { event in
///                     switch event {
///                     case .connected:
///                         print("Socket ready")
///                     case .message(let msg):
///                         if case .text(let text) = msg { print("Received: \(text)") }
///                     case .disconnected(let code, _):
///                         print("Closed with code \(code.rawValue)")
///                     }
///                 }
///                 .store(in: &self!.cancellables)
///         }
///     )
///     .store(in: &cancellables)
///
/// // Send a message after connecting:
/// Task { try? await connection?.send(.text("hello")) }
///
/// // Close gracefully:
/// connection?.disconnect()
/// ```
public final class WebSocketConnection {

    /// Emits `WebSocketEvent` values for the lifetime of the connection.
    ///
    /// Completes with `.finished` after a clean `disconnected` event,
    /// or with a `.failure` on an unexpected network error.
    public let events: AnyPublisher<WebSocketEvent, Error>

    private let task: URLSessionWebSocketTask

    init(task: URLSessionWebSocketTask, events: AnyPublisher<WebSocketEvent, Error>) {
        self.task = task
        self.events = events
    }

    // MARK: - Send

    /// Sends a text or binary message to the server.
    /// - Throws: A `URLError` if the connection is not open or the send fails.
    public func send(_ message: WebSocketMessage) async throws {
        switch message {
        case .text(let string):
            try await task.send(.string(string))
        case .data(let data):
            try await task.send(.data(data))
        }
    }

    // MARK: - Disconnect

    /// Closes the connection with the given close code.
    ///
    /// The `events` publisher will emit `.disconnected` and then complete.
    /// Calls after the connection is already closed are no-ops.
    ///
    /// - Parameters:
    ///   - closeCode: The WebSocket close code. Defaults to `.normalClosure` (1000).
    ///   - reason: An optional UTF-8 encoded reason string (max 123 bytes per spec).
    public func disconnect(
        closeCode: URLSessionWebSocketTask.CloseCode = .normalClosure,
        reason: Data? = nil
    ) {
        task.cancel(with: closeCode, reason: reason)
    }
}
