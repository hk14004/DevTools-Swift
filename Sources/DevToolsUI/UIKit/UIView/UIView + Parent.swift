//
//  UIView + Parent.swift
//  
//
//  Created by Hardijs Ķirsis on 06/05/2023.
//

import UIKit

public extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
}
