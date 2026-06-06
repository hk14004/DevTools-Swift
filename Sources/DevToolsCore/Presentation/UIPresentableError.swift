//
//  UIPresentableError.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 09/06/2025.
//

import Foundation

public protocol UIPresentableError: Error {
    var presentableContent: UIPresentableErrorContent { get }
}

public struct UIPresentableErrorContent {
    public let title: String
    public let message: String
    
    public init(title: String = "", message: String = "") {
        self.title = title
        self.message = message
    }
}
