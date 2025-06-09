//
//  UIPresentableError.swift
//  DevTools
//
//  Created by Hardijs Kirsis on 09/06/2025.
//

import Foundation

protocol UIPresentableError: Error {
    var presentableContent: UIPresentableErrorContent { get }
}

public struct UIPresentableErrorContent {
    let title: String
    let message: String
    
    public init(title: String = "", message: String = "") {
        self.title = title
        self.message = message
    }
}
