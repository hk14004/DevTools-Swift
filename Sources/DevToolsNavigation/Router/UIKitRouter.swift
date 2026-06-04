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

    /// Wraps `vc` in a `UINavigationController` and presents it modally.
    /// Use this for modal flows that need their own navigation bar (e.g. a settings sheet with sub-screens).
    func presentInNavigationController(
        _ vc: UIViewController,
        navigationControllerClass: UINavigationController.Type = UINavigationController.self,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let nav = navigationControllerClass.init(rootViewController: vc)
        viewController?.present(nav, animated: animated, completion: completion)
    }

    /// Replaces the entire navigation stack.
    /// Use this for transitions where the back stack must be cleared entirely (e.g. login → home).
    func setStack(_ viewControllers: [UIViewController], animated: Bool = true) {
        navigationController?.setViewControllers(viewControllers, animated: animated)
    }

    /// Replaces the top view controller without leaving it in the back stack.
    /// Use this for redirect-style transitions where the user shouldn't be able to go back (e.g. step 1 → step 2 in an onboarding flow).
    func replaceTop(with vc: UIViewController, animated: Bool = true) {
        guard let navController = navigationController else { return }
        var stack = navController.viewControllers
        guard !stack.isEmpty else {
            navController.setViewControllers([vc], animated: animated)
            return
        }
        stack[stack.count - 1] = vc
        navController.setViewControllers(stack, animated: animated)
    }

    /// Pops back to the first view controller of the given type in the navigation stack.
    /// Use this after completing a multi-step flow to land on a specific earlier screen.
    @discardableResult
    func popTo(_ type: UIViewController.Type, animated: Bool = true) -> Bool {
        guard let navController = navigationController,
              let target = navController.viewControllers.first(where: { $0.isKind(of: type) }) else {
            return false
        }
        navController.popToViewController(target, animated: animated)
        return true
    }

    /// Opens a URL via UIApplication (browser, phone, mailto, etc.).
    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }

    /// Opens the app's own page in iOS Settings.
    /// Use this after a permission is denied to let the user enable it manually.
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
