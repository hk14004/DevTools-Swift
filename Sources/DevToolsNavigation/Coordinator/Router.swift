////
////  Router.swift
////  
////
////  Created by Hardijs on 31/12/2022.
////
//
//import UIKit
//
//public typealias NavigationBackClosure = (() -> ())
//
//public protocol RouterProtocol: AnyObject {
//    func push(_ vc: UIViewController, isAnimated: Bool, onNavigateBack: NavigationBackClosure?)
//    func pop(_ isAnimated: Bool)
//    func popToRoot(_ isAnimated: Bool)
//    var navigationController: UINavigationController { get }
//}
//
//public class Router : NSObject, RouterProtocol {
//    public let navigationController: UINavigationController
//    private var closures: [String: NavigationBackClosure] = [:]
//
//    public init(navigationController: UINavigationController) {
//        self.navigationController = navigationController
//        super.init()
//        self.navigationController.delegate = self
//    }
//
//    public func push(_ vc: UIViewController, isAnimated: Bool, onNavigateBack closure: NavigationBackClosure?) {
//        if let closure = closure {
//            closures.updateValue(closure, forKey: vc.description)
//        }
//        navigationController.pushViewController(vc, animated: isAnimated)
//    }
//
//    public func pop(_ isAnimated: Bool) {
//        navigationController.popViewController(animated: isAnimated)
//    }
//    
//    public func popToRoot(_ isAnimated: Bool) {
//        navigationController.popToRootViewController(animated: isAnimated)
//    }
//    
//    private func executeClosure(_ viewController: UIViewController) {
//        guard let closure = closures.removeValue(forKey: viewController.description) else { return }
//        closure()
//    }
//}
//
//extension Router : UINavigationControllerDelegate {
//    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        guard let previousController = navigationController.transitionCoordinator?.viewController(forKey: .from),
//            !navigationController.viewControllers.contains(previousController) else {
//                return
//        }
//        executeClosure(previousController)
//    }
//}
