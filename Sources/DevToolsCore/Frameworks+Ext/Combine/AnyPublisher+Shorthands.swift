import Combine
import Foundation

public extension AnyPublisher {
    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        Just(output).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }
    
    static func empty() -> AnyPublisher<Output, Failure> {
        Empty(outputType: Output.self, failureType: Failure.self).eraseToAnyPublisher()
    }
    
    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        Fail(error: error).eraseToAnyPublisher()
    }
    
    func mapToVoid() -> Publishers.Map<AnyPublisher<Output, Failure>, Void> {
        map { _ in () }
    }
    
    func mapTo(_ output: Output) -> Publishers.Map<AnyPublisher<Output, Failure>, Output> {
        map { _ in output }
    }
}
