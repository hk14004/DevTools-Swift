//
//  UIStoryBoard + Ext.swift
//
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

extension UIStoryboard {
    public static func instantiateViewController<T: UIViewController>(type: T.Type, creator: ((NSCoder) -> T)?) -> T! {
        let id = "\(T.self)"
        let storyboard = UIStoryboard(name: id, bundle: nil)
        return storyboard.instantiateViewController(identifier: id, creator: creator)
    }
    
    public static func instantiateViewController<T: UIViewController>(type: T.Type) -> T! {
        let id = "\(T.self)"
        let storyboard = UIStoryboard(name: id, bundle: nil)
        return (storyboard.instantiateViewController(withIdentifier: id) as! T)
    }
}
