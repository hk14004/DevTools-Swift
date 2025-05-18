//
//  LocalizedRuntimeComponent.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation

protocol RuntimeLocalizedUIKitComponent {
    var runtimeLocalizedKey: String? { get set }
    var runtimeLocalizedArguments: [CVarArg] { get set }
    func updateRuntimeLocalizedStrings()
}
