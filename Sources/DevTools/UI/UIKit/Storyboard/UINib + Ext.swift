//
//  UINib + Ext.swift
//  
//
//  Created by Hardijs on 31/12/2022.
//

import UIKit

extension UINib {
    static func instanciateNib<T: UITableViewCell>(type: T.Type) -> UINib! {
        return .init(nibName: "\(type)", bundle: nil)
    }
}
