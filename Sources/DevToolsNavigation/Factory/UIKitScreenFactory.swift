//
//  UIKitScreenFactory.swift
//  DevTools
//
//  Created by Hardijs on 28/08/2025.
//

import UIKit

/// Builds a `UIViewController` from a given set of parameters.
///
/// Use this to decouple screen creation from navigation logic. The factory
/// knows how to wire up a screen (ViewModel, dependencies, router injection);
/// the router just asks for the screen and pushes it.
///
/// # Defining a factory
/// ```swift
/// struct ProductScreenFactory: UIKitScreenFactory {
///     let dependencies: AppDependencies
///
///     func make(params: ProductScreenParams) -> UIViewController {
///         let router = DefaultProductRouter(...)
///         let viewModel = ProductViewModel(id: params.id, router: router)
///         return ProductViewController(viewModel: viewModel)
///     }
/// }
/// ```
///
/// # Using with a UIKitRouter
/// ```swift
/// class DefaultHomeRouter: UIKitRouter, HomeRouter {
///     weak var viewController: UIViewController?
///     let productFactory: ProductScreenFactory
///
///     func routeToProduct(id: String) {
///         let vc = productFactory.make(params: .init(id: id))
///         push(vc)
///     }
/// }
/// ```
public protocol UIKitScreenFactory {
    associatedtype Params
    func make(params: Params) -> UIViewController
}
