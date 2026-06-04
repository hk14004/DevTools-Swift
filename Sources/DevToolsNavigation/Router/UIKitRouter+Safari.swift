//
//  UIKitRouter+Safari.swift
//  DevTools
//
//  Created by Hardijs on 04/06/2026.
//

import SafariServices
import UIKit

public extension UIKitRouter {

    /// Presents a `SFSafariViewController` for the given URL.
    /// Use this for in-app web browsing where you want to keep the user inside the app.
    func presentSafari(
        _ url: URL,
        configuration: SFSafariViewController.Configuration = .init(),
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let safari = SFSafariViewController(url: url, configuration: configuration)
        viewController?.present(safari, animated: animated, completion: completion)
    }
}
