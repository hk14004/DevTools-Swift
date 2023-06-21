//
//  UINib + Ext.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

extension UINib {
    public static func instanciateNib<T: UITableViewCell>(type: T.Type) -> UINib! {
        return .init(nibName: "\(type)", bundle: nil)
    }
    public static func instanciateNib<T: UICollectionViewCell>(type: T.Type) -> UINib! {
        return .init(nibName: "\(type)", bundle: nil)
    }
    public static func instanciateNib<T: UITableViewHeaderFooterView>(type: T.Type) -> UINib! {
        return .init(nibName: "\(type)", bundle: nil)
    }
}
