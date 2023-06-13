//
//  SubtitleTableViewCell.swift
//  
//
//  Created by Hardijs Ķirsis on 13/06/2023.
//

import UIKit

public class SubtitleTableViewCell: UITableViewCell {
    
    public static let reuseID = String(describing: SubtitleTableViewCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
