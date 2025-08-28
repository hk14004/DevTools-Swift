//
//  ToErrorRouting.swift
//  DevTools
//
//  Created by Hardijs on 22/08/2025.
//

import Foundation

public protocol ToErrorRouting {
    func routeToOkeyErrorAlert(_ error: Error, onDismiss: (() -> Void)?)
}
