//
//  UIHostingController+SafeArea.swift
//
//
//  Created by Hardijs Ķirsis on 25/04/2023.
//

import SwiftUI

public extension UIHostingController {

    /// Initialises a hosting controller with an option to ignore safe area insets.
    ///
    /// Uses `safeAreaRegions = []` rather than the fragile Objective-C runtime override used
    /// previously. `safeAreaRegions` is iOS 16.4+, so on iOS 16.0–16.3 this is a no-op.
    ///
    /// ```swift
    /// let host = UIHostingController(rootView: MyView(), ignoreSafeArea: true)
    /// ```
    convenience init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)
        if ignoreSafeArea {
            if #available(iOS 16.4, *) { safeAreaRegions = [] }
        }
    }
}
