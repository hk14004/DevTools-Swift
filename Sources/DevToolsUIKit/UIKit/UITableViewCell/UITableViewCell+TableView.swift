//
//  UITableViewCell+TableView.swift
//  
//
//  Created by Hardijs Ķirsis on 06/05/2023.
//

import UIKit

public extension UITableViewCell {
    var tableView: UITableView? {
        return parentView(of: UITableView.self)
    }
    
    func updateCell() {
        let table = tableView
        table?.beginUpdates()
        table?.endUpdates()
    }
}
