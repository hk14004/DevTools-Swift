//
//  LocalizedRuntimeComponent.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation

protocol LocalizedRuntimeComponent {
    var stringsFileKey: String? { get set }
    func updateText()
}
