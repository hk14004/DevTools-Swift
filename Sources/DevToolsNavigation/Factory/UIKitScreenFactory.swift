//
//  UIKitScreenFactory.swift
//  DevTools
//
//  Created by Hardijs on 28/08/2025.
//

import UIKit

public protocol UIKitScreenFactory {
    associatedtype ViewController: UIViewController
    associatedtype Dependencies
    func make(di: Dependencies) -> ViewController
}
