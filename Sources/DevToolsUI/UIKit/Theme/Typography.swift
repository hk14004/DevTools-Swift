//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 09/09/2023.
//

import UIKit

public protocol DevTypography: CaseIterable {
    var scaledFont: UIFont { get }
}


fileprivate enum ExampleAppTypography: DevTypography {
    case title
    case body
    
    var scaledFont: UIFont {
        switch self {
        case .body:
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 12))
        case .title:
            return UIFontMetrics(forTextStyle: .title1).scaledFont(for: .boldSystemFont(ofSize: 12))
        }
    }
}
