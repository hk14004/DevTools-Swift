//
//  Constraints.swift
//  
//
//  Created by Hardijs Ķirsis on 05/05/2023.
//

import UIKit

public extension UIView {
    func pinToSuperviewEdges(useSafeArea: Bool) {
        guard let superview = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let topAnchor: NSLayoutYAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor
        
        if useSafeArea {
            topAnchor = superview.safeAreaLayoutGuide.topAnchor
            bottomAnchor = superview.safeAreaLayoutGuide.bottomAnchor
        } else {
            topAnchor = superview.topAnchor
            bottomAnchor = superview.bottomAnchor
        }
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: topAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
