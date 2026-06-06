//
//  UINib+Ext.swift
//
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

public extension UINib {
    static func instantiateNib<T: UITableViewCell>(type: T.Type) -> UINib {
        UINib(nibName: "\(type)", bundle: nil)
    }
    static func instantiateNib<T: UICollectionViewCell>(type: T.Type) -> UINib {
        UINib(nibName: "\(type)", bundle: nil)
    }
    static func instantiateNib<T: UITableViewHeaderFooterView>(type: T.Type) -> UINib {
        UINib(nibName: "\(type)", bundle: nil)
    }
}
