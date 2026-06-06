import Combine

extension Publisher {
    /// Subscribes to the publisher, handling only error completions.
    /// `.finished` is silently ignored.
    public func sink(
        receiveValue: @escaping (Self.Output) -> Void,
        completionError: @escaping (Self.Failure) -> Void
    ) -> AnyCancellable {
        sink(
            receiveCompletion: { if case .failure(let error) = $0 { completionError(error) } },
            receiveValue: receiveValue
        )
    }
}
