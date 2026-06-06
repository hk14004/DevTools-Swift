//
//  UIViewController+UIStoryboard.swift
//
//
//  Created by Hardijs Ķirsis on 11/06/2023.
//

import UIKit

public extension UIViewController {

    /// Instantiates this view controller from a storyboard using a custom creator for dependency injection.
    ///
    /// The storyboard name and scene identifier must both match the view controller's type name.
    /// Triggers `fatalError` if either is not found.
    static func instantiateViewController<T: UIViewController>(creator: ((NSCoder) -> T)?) -> T {
        UIStoryboard.instantiateViewController(type: T.self, creator: creator)
    }

    /// Instantiates this view controller from a storyboard.
    ///
    /// The storyboard name and scene identifier must both match the view controller's type name.
    /// Triggers `fatalError` if either is not found.
    static func instantiateViewController() -> Self {
        UIStoryboard.instantiateViewController(type: Self.self)
    }
}
