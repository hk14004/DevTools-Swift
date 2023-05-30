//
//  AppearanceProxy.swift
//  
//
//  Created by Hardijs Ķirsis on 30/05/2023.
//

import UIKit

public class AppearanceProxy {
    let navBarAppearance = UINavigationBarAppearance()
}

// MARK: Public

public extension AppearanceProxy {
    
    // MARK: Accent
    
    static func setDefault(controlTintColor: UIColor) {
        UIControl.appearance().tintColor = controlTintColor
        UIProgressView.appearance().tintColor = controlTintColor
    }
    
    // MARK: Content
    
    static func setDefault(contentTextColor: UIColor) {
        UILabel.appearance().textColor = contentTextColor
        UITextField.appearance().textColor = contentTextColor
        UITextView.appearance().textColor = contentTextColor
    }
    
    static func setDefault(contentFont: UIFont) {
        UILabel.appearance().font = contentFont
        UITextField.appearance().font = contentFont
        UITextView.appearance().font = contentFont
    }
    
    // MARK: Navigation bar
    
    static func setDefault(navigationBarAppearance: UINavigationBarAppearance) {
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    
    static func setDefault(navigationBarControlColor: UIColor) {
        UINavigationBar.appearance().tintColor = navigationBarControlColor
    }
    
    // MARK: Status bar
    
    // MARK: Tab bar
    
}
