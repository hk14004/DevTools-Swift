//
//  Typography.swift
//
//
//  Created by Hardijs Ķirsis on 09/09/2023.
//

import UIKit

/// Conform to this protocol to define your app's type scale.
///
/// Each case represents a text style and returns a Dynamic Type-aware font.
///
/// ```swift
/// enum AppTypography: DevTypography {
///     case title
///     case body
///
///     var scaledFont: UIFont {
///         switch self {
///         case .title: return UIFontMetrics(forTextStyle: .title1).scaledFont(for: .boldSystemFont(ofSize: 20))
///         case .body:  return UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16))
///         }
///     }
/// }
/// ```
public protocol DevTypography: CaseIterable {
    var scaledFont: UIFont { get }
}
