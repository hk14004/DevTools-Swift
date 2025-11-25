//
//  XCTest+Combine.swift
//
//
//  Created by Hardijs Ķirsis on 24/10/2023.
//

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
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = self.expectation(description: "Awaiting publisher")
        
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
        
        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )
        
        return try unwrappedResult.get()
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
