//
//  UITableView+Dequeue.swift
//
//
//  Created by Hardijs Ķirsis on 29/12/2023.
//

import UIKit

public extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
    }
}
