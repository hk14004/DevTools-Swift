//
//  SwiftUIScreenFactory.swift
//  DevTools
//
//  Created by Hardijs on 28/08/2025.
//

import SwiftUI

public protocol SwiftUIScreenFactory {
    associatedtype Params
    func make(params: Params) -> any View
}
