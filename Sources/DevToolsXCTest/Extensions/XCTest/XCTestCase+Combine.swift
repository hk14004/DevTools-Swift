//
//  XCTest+Combine.swift
//
//
//  Created by Hardijs Ķirsis on 24/10/2023.
//

#if canImport(XCTest)
import XCTest
import Combine

public extension Result {
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        case .failure(_):
            return false
        }
    }
    
    var isFailure: Bool {
        switch self {
        case .success(_):
            return false
        case .failure(_):
            return true
        }
    }
    
    var value: Result.Publisher.Output? {
        switch self {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }
}

public extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Result<T.Output, Error>? {
        var result: Result<T.Output, Error>?
        let expectation = expectation(description: "Awaiting publisher file: \(file), line:\(line)")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                case .finished:
                    break
                }

                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        return result
    }
}

// Used to capture stream of next values during unit tests
public extension Published.Publisher {
    func collectNext(_ count: Int) -> AnyPublisher<[Output], Never> {
        dropFirst()
            .collect(count)
            .first()
            .eraseToAnyPublisher()
    }
}
#endif
