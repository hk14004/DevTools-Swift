//
//  MockHTTPURLResponse.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import Foundation

extension HTTPURLResponse {
    static func mock(url: String, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
