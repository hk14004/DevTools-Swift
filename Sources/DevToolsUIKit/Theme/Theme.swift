//
//  Theme.swift
//  
//
//  Created by Hardijs Ķirsis on 08/09/2023.
//

import UIKit

public protocol DevTheme {
    // MARK: - Misc
    static var roundedCornerRadius: CGFloat { get set }
    
    // MARK: - Backgrounds
    static var contentColor: UIColor { get set }
    static var backgroundColor: UIColor { get set }
    
    // MARK: - Buttons
    static var uIControlColor: UIColor { get set }
    
    // MARK: - Texts
    static var textColor: UIColor { get set }
    static var secondaryTextColor: UIColor { get set }
    static var placeHolderTextColor: UIColor { get set }
    static var textLinkColor: UIColor { get set }
}
