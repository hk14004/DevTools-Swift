//
//  StoryboardLoadableView.swift
//  
//
//  Created by Hardijs Ķirsis on 12/06/2023.
//

import UIKit

public protocol StoryboardLoadableView: UIView {
    var loadedXibView: UIView! { get set }
    func commonXibInit()
}

public extension StoryboardLoadableView {
    func commonXibInit() {
        backgroundColor = .clear
        let name = String(describing: type(of: self))
        loadedXibView = Bundle.main.loadNibNamed(name, owner: self)!.first as? UIView
        addSubview(loadedXibView)
        
        loadedXibView.translatesAutoresizingMaskIntoConstraints = false
        loadedXibView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        loadedXibView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        loadedXibView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        loadedXibView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
