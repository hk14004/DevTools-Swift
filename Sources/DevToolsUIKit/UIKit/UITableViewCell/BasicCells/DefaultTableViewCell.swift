//
//  DefaultTableViewCell.swift
//  
//
//  Created by Hardijs Ķirsis on 13/06/2023.
//

import UIKit

public class DefaultTableViewCell: UITableViewCell {
    
    public static let reuseID = String(describing: DefaultTableViewCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
