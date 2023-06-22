//
//  UIView + Constraints.swift
//  
//
//  Created by Hardijs Ķirsis on 06/05/2023.
//

import UIKit

public extension UIView {
    func pinToSuperviewEdges(pinToSafeArea: Bool) {
        guard let superview = superview else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let topAnchor: NSLayoutYAxisAnchor
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor
        
        if pinToSafeArea {
            topAnchor = superview.safeAreaLayoutGuide.topAnchor
            leadingAnchor = superview.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = superview.safeAreaLayoutGuide.trailingAnchor
            bottomAnchor = superview.safeAreaLayoutGuide.bottomAnchor
        } else {
            topAnchor = superview.topAnchor
            leadingAnchor = superview.leadingAnchor
            trailingAnchor = superview.trailingAnchor
            bottomAnchor = superview.bottomAnchor
        }
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: topAnchor),
            self.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
