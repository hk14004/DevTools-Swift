//
//  Theme.swift
//  
//
//  Created by Hardijs Ķirsis on 08/09/2023.
//

import UIKit

public protocol DevTheme {
    // MARK: - Misc
    var roundedCornerRadius: CGFloat { get set }
    
    // MARK: - Backgrounds
    var contentColor: UIColor { get set }
    var backgroundColor: UIColor { get set }
    
    // MARK: - Buttons
    var uIControlColor: UIColor { get set }
    
    // MARK: - Texts
    var textColor: UIColor { get set }
    var secondaryTextColor: UIColor { get set }
    var placeHolderTextColor: UIColor { get set }
    var textLinkColor: UIColor { get set }
}
