//
//  XCTestCase+MockError.swift
//  DevTools
//
//  Created by Hardijs on 27/11/2025.
//

import XCTest

public extension XCTestCase {
    var mockedError: Error {
        NSError(domain: "MockError", code: 11, userInfo: nil)
    }
}
