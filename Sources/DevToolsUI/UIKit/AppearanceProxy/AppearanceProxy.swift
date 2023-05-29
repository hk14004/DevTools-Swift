//
//  AppearanceProxy.swift
//  
//
//  Created by Hardijs Ķirsis on 30/05/2023.
//

import UIKit

public class AppearanceProxy {
    
}

// MARK: Public

public extension AppearanceProxy {
    
    // MARK: Content
    
    static func setDefault(contentTextColor: UIColor) {
        UILabel.appearance().textColor = contentTextColor
        UITextField.appearance().textColor = contentTextColor
        UITextView.appearance().textColor = contentTextColor
        UIButton.appearance().setTitleColor(contentTextColor, for: .normal)
    }
    
    static func setDefault(contentFont: UIFont) {
        UILabel.appearance().font = contentFont
        UITextField.appearance().font = contentFont
        UITextView.appearance().font = contentFont
    }
    
    static func setDefault(contentBackgroundColor: UIColor) {
        UIView.appearance().backgroundColor = contentBackgroundColor
    }
    
    static func setDefault(controlTintColor: UIColor) {
        UIControl.appearance().tintColor = controlTintColor
    }
    
    // MARK: Navigation bar
    
    static func setDefault(navigationBarBackgroundColor: UIColor) {
        UINavigationBar.appearance().barTintColor = navigationBarBackgroundColor
    }
    
    static func setDefault(navigationBarTitleTextAttributes: [NSAttributedString.Key: Any]) {
        UINavigationBar.appearance().titleTextAttributes = navigationBarTitleTextAttributes
    }
    
    static func setDefault(navigationBarTranslucent: Bool) {
        UINavigationBar.appearance().isTranslucent = navigationBarTranslucent
    }
    
    static func setDefault(navigationBarShadowImage: UIImage?) {
        UINavigationBar.appearance().shadowImage = navigationBarShadowImage
    }
    
    static func setDefault(navigationBarBackgroundImage: UIImage?) {
        UINavigationBar.appearance().setBackgroundImage(navigationBarBackgroundImage, for: .default)
    }
    
    static func setDefault(navigationBarBackIndicatorImage: UIImage?) {
        UINavigationBar.appearance().backIndicatorImage = navigationBarBackIndicatorImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = navigationBarBackIndicatorImage
    }
    
    static func setDefault(navigationBarTintColor: UIColor) {
        UINavigationBar.appearance().tintColor = navigationBarTintColor
    }
    
    // MARK: Status bar
    
}
