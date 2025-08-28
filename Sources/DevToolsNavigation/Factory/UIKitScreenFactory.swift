//
//  UIKitScreenFactory.swift
//  DevTools
//
//  Created by Hardijs on 28/08/2025.
//

import UIKit

public protocol UIKitScreenFactory {
    associatedtype Params
    func make(params: Params) -> UIViewController
}
