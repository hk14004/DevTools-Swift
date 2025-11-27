//
//  XCTestCase+MockError.swift
//  DevTools
//
//  Created by Hardijs on 27/11/2025.
//

import XCTest

public extension XCTestCase {
    enum MockError: Error, Equatable {
        case fakeIssue
    }
    
    var mockedError: MockError {
        .fakeIssue
    }
}
