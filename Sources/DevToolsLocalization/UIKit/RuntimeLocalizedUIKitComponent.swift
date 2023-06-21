//
//  LocalizedRuntimeComponent.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation

protocol RuntimeLocalizedUIKitComponent {
    var runtimeLocalizedKey: String? { get set }
    func updateRuntimeLocalizedStrings()
}
