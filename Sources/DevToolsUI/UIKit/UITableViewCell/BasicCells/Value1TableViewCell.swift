//
//  Value1TableViewCell.swift
//  
//
//  Created by Hardijs Ķirsis on 13/06/2023.
//

import UIKit

public class Value1TableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
