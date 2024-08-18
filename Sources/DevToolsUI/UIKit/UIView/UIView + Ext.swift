//
//  UIView + Ext.swift
//  
//
//  Created by Hardijs Ķirsis on 13/06/2023.
//

import UIKit

public extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
    
    @available(iOS 13.4, *)
    func setMargins(direction: UIAxis, constant: CGFloat, ignoreSuperViewMargins: Bool? = nil) {
        if let ignoreSuperViewMargins = ignoreSuperViewMargins {
            preservesSuperviewLayoutMargins = !ignoreSuperViewMargins
        }
        
        switch direction {
        case .both:
            directionalLayoutMargins = .init(top: constant, leading: constant,
                                             bottom: constant, trailing: constant)
        case .horizontal:
            directionalLayoutMargins.leading = constant
            directionalLayoutMargins.trailing = constant
        case .vertical:
            directionalLayoutMargins.top = constant
            directionalLayoutMargins.bottom = constant
        default:
            directionalLayoutMargins = .init(top: constant, leading: constant,
                                             bottom: constant, trailing: constant)
        }
    }
}
