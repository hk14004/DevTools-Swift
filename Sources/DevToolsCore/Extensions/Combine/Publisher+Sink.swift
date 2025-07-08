import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func sink(
        optional receiveCompletion: @escaping (Subscribers.Completion<Self.Failure>) -> Void = { _ in },
        optional receiveValue: @escaping (Self.Output) -> Void = { _ in }
    ) -> AnyCancellable {
        return sink(
            receiveCompletion: receiveCompletion,
            receiveValue: receiveValue
        )
    }
    
    public func sink(
        receiveValue: @escaping (Self.Output) -> Void,
        completionError: @escaping (Self.Failure) -> Void
    ) -> AnyCancellable {
        return self.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    completionError(error)
                }
            },
            receiveValue: receiveValue
        )
    }
}
