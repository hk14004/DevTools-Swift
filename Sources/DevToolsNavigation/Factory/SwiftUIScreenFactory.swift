//
//  UIKitScreenFactory.swift
//  DevTools
//
//  Created by Hardijs on 28/08/2025.
//

import SwiftUI

public protocol SwiftUIScreenFactory {
    associatedtype Dependencies
    func make(di: Dependencies) -> any View
}
