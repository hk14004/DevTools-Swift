import Combine

extension Publisher {
    public func mapCatch(
        _ handler: @escaping (Self.Failure) -> AnyPublisher<Self.Output, Self.Failure>
    ) -> AnyPublisher<Self.Output, Self.Failure> {
        tryCatch { error -> AnyPublisher<Self.Output, Self.Failure> in
            handler(error)
        }
        .mapError { error -> Self.Failure in
            guard let error = error as? Self.Failure else {
                preconditionFailure()
            }
            return error
        }
        .eraseToAnyPublisher()
    }
}
