//
//  UITableViewCell+RegisterCell.swift
//  
//
//  Created by Hardijs Ķirsis on 29/12/2023.
//

import UIKit

public extension UITableView {
    func registerCell<T: UITableViewCell>(_ cellType: T.Type) {
        register(cellType, forCellReuseIdentifier: String(describing: cellType.self))
    }
}
