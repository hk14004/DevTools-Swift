//
//  UIViewController + UIStoryboard.swift
//  
//
//  Created by Hardijs Ķirsis on 11/06/2023.
//

import UIKit

public extension UIViewController {
    static func instantiateViewController(creator: ((NSCoder) -> Self)?) -> Self! {
        return UIStoryboard.instantiateViewController(type: Self.self, creator: creator)!
    }
    
    static func instantiateViewController() -> Self! {
        return UIStoryboard.instantiateViewController(type: Self.self)!
    }
}
