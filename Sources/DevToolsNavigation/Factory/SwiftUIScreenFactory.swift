//
//  SwiftUIScreenFactory.swift
//  DevTools
//
//  Created by Hardijs on 28/08/2025.
//

import SwiftUI

/// Builds a SwiftUI `View` from a given set of parameters.
///
/// In a `SwiftUICoordinator`, screen building is often inlined into the
/// coordinator's `view(for:)` method. Use `SwiftUIScreenFactory` when you
/// want to move that logic into a dedicated, injectable object — useful
/// for larger features or when the same screen is reused across coordinators.
///
/// # Defining a factory
/// ```swift
/// struct ProductScreenFactory: SwiftUIScreenFactory {
///     let dependencies: AppDependencies
///
///     func make(params: ProductScreenParams) -> some View {
///         let viewModel = ProductViewModel(id: params.id, dependencies: dependencies)
///         return ProductView(viewModel: viewModel)
///     }
/// }
/// ```
///
/// # Using inside a SwiftUICoordinator
/// ```swift
/// @Observable
/// class HomeCoordinator: SwiftUICoordinator, HomeRouter {
///     var path = NavigationPath()
///     let productFactory: ProductScreenFactory
///
///     @ViewBuilder
///     func view(for route: HomeRoute) -> some View {
///         switch route {
///         case .productDetail(let id):
///             productFactory.make(params: .init(id: id))
///         }
///     }
///
///     func routeToProduct(id: String) { push(HomeRoute.productDetail(id: id)) }
/// }
/// ```
///
/// # Without a factory (inlined — fine for simple coordinators)
/// ```swift
/// @ViewBuilder
/// func view(for route: HomeRoute) -> some View {
///     switch route {
///     case .productDetail(let id): ProductView(id: id)
///     }
/// }
/// ```
public protocol SwiftUIScreenFactory {
    associatedtype Params
    func make(params: Params) -> any View
}
