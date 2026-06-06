//
//  UIStoryboard+Ext.swift
//
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

public extension UIStoryboard {

    /// Instantiates a view controller whose storyboard name and scene identifier both match
    /// the type name, using a custom creator for dependency injection.
    ///
    /// Triggers `fatalError` if the storyboard or identifier is not found —
    /// a mismatch here is always a programmer error, not a runtime condition.
    static func instantiateViewController<T: UIViewController>(type: T.Type, creator: ((NSCoder) -> T)?) -> T {
        let id = "\(T.self)"
        let storyboard = UIStoryboard(name: id, bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: id, creator: creator) as? T else {
            fatalError("Could not instantiate '\(id)' from storyboard '\(id)'. Verify the storyboard file exists and the scene identifier matches.")
        }
        return vc
    }

    /// Instantiates a view controller whose storyboard name and scene identifier both match the type name.
    ///
    /// Triggers `fatalError` if the storyboard or identifier is not found.
    static func instantiateViewController<T: UIViewController>(type: T.Type) -> T {
        let id = "\(T.self)"
        let storyboard = UIStoryboard(name: id, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: id) as? T else {
            fatalError("Could not instantiate '\(id)' from storyboard '\(id)'. Verify the storyboard file exists and the scene identifier matches.")
        }
        return vc
    }
}
