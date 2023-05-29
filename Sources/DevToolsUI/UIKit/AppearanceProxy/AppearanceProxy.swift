//
//  AppearanceProxy.swift
//  
//
//  Created by Hardijs Ķirsis on 30/05/2023.
//

import UIKit

class AppearanceProxy {
    
}

// MARK: Public

extension AppearanceProxy {
    
    // MARK: Content
    
    func setDefault(contentTextColor: UIColor) {
        UILabel.appearance().textColor = contentTextColor
        UITextField.appearance().textColor = contentTextColor
        UITextView.appearance().textColor = contentTextColor
        UIButton.appearance().setTitleColor(contentTextColor, for: .normal)
    }
    
    func setDefault(contentFont: UIFont) {
        UILabel.appearance().font = contentFont
        UITextField.appearance().font = contentFont
        UITextView.appearance().font = contentFont
    }
    
    func setDefault(contentBackgroundColor: UIColor) {
        UIView.appearance().backgroundColor = contentBackgroundColor
    }
    
    func setDefault(controlTintColor: UIColor) {
        UIControl.appearance().tintColor = controlTintColor
    }
    
    // MARK: Navigation bar
    
    func setDefault(navigationBarBackgroundColor: UIColor) {
        UINavigationBar.appearance().barTintColor = navigationBarBackgroundColor
    }
    
    func setDefault(navigationBarTitleTextAttributes: [NSAttributedString.Key: Any]) {
        UINavigationBar.appearance().titleTextAttributes = navigationBarTitleTextAttributes
    }
    
    func setDefault(navigationBarTranslucent: Bool) {
        UINavigationBar.appearance().isTranslucent = navigationBarTranslucent
    }
    
    func setDefault(navigationBarShadowImage: UIImage?) {
        UINavigationBar.appearance().shadowImage = navigationBarShadowImage
    }
    
    func setDefault(navigationBarBackgroundImage: UIImage?) {
        UINavigationBar.appearance().setBackgroundImage(navigationBarBackgroundImage, for: .default)
    }
    
    func setDefault(navigationBarBackIndicatorImage: UIImage?) {
        UINavigationBar.appearance().backIndicatorImage = navigationBarBackIndicatorImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = navigationBarBackIndicatorImage
    }
    
    func setDefault(navigationBarTintColor: UIColor) {
        UINavigationBar.appearance().tintColor = navigationBarTintColor
    }
    
    // MARK: Status bar
    
}
