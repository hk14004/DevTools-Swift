//
//  MockHTTPURLResponse.swift
//
//
//  Created by Hardijs Ķirsis on 14/08/2024.
//

import Foundation

extension HTTPURLResponse {
    static func mock(url: String) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: url)!,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
    }
}
