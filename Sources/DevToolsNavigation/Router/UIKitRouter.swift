//
//  UIKitRouter.swift
//
//
//  Created by Hardijs Ķirsis on 25/10/2023.
//

import UIKit

public protocol UIKitRouter {
    var viewController: UIViewController? { get set }
}

public extension UIKitRouter {
    var navigationController: UINavigationController? {
        if let navVC = viewController as? UINavigationController {
            return navVC
        } else {
            return viewController?.navigationController
        }
    }
}
