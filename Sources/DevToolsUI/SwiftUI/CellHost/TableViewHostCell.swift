//
//  TableViewHostCell.swift
//  
//
//  Created by Hardijs Ķirsis on 25/04/2023.
//

import SwiftUI

class TableViewHostCell<Cell: View>: UITableViewCell {
    private var hostController: UIHostingController<Cell>?
    
    var hostedCell: Cell? {
        willSet {
            if let hostView = hostController?.view {
                hostView.removeFromSuperview()
            }
            hostController = nil
            guard let view = newValue else { return }
            hostController = UIHostingController(rootView: view, ignoreSafeArea: true)
            if let hostView = hostController?.view {
                contentView.addSubview(hostView)
                hostController?.view.backgroundColor = .clear
                hostController?.view.translatesAutoresizingMaskIntoConstraints = false
                hostController?.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                hostController?.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
                hostController?.view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
                hostController?.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            }
        }
    }
}
