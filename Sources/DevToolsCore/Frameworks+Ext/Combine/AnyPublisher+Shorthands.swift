import Combine
import Foundation

extension AnyPublisher {
    public static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        Just(output).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }
    
    public static func empty() -> AnyPublisher<Output, Failure> {
        Empty(outputType: Output.self, failureType: Failure.self).eraseToAnyPublisher()
    }
    
    public static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        Fail(error: error).eraseToAnyPublisher()
    }
    
    public func mapToVoid() -> Publishers.Map<AnyPublisher<Output, Failure>, Void> {
        map { _ in () }
    }
    
    public func mapTo(_ output: Output) -> Publishers.Map<AnyPublisher<Output, Failure>, Output> {
        map { _ in output }
    }
}
