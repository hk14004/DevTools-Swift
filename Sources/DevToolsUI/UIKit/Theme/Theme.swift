//
//  Theme.swift
//  
//
//  Created by Hardijs Ķirsis on 08/09/2023.
//

import UIKit

public protocol DevTheme {
    associatedtype TypographyType: DevTypography
    
    // MARK: - Misc
    var roundedCornerRadius: CGFloat { get set }
    
    // MARK: - Backgrounds
    var contentColor: UIColor { get set }
    var backgroundColor: UIColor { get set }
    
    // MARK: - Buttons
    var primaryUIControlColor: UIColor { get set }
    
    // MARK: - Texts
    var typography: TypographyType { get }
    var textColor: UIColor { get set }
    var secondaryTextColor: UIColor { get set }
    var placeHolderTextColor: UIColor { get set }
    var textLinkColor: UIColor { get set }
}
