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
    /// Uses `safeAreaRegions = []` (available iOS 16+, covered by the iOS 17 minimum target)
    /// rather than the fragile Objective-C runtime override used previously.
    ///
    /// ```swift
    /// let host = UIHostingController(rootView: MyView(), ignoreSafeArea: true)
    /// ```
    convenience init(rootView: Content, ignoreSafeArea: Bool) {
        self.init(rootView: rootView)
        if ignoreSafeArea {
            safeAreaRegions = []
        }
    }
}
