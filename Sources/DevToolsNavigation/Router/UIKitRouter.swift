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

    func push(_ vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }

    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

    func present(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.present(vc, animated: animated, completion: completion)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.dismiss(animated: animated, completion: completion)
    }
}
