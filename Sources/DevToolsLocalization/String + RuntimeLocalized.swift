//
//  String + RuntimeLocalized.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import SwiftUI

public extension String {
    func runtimeLocalized() -> String {
        let bundle = RuntimeStringFileLocalization.shared.bundle
        if let path = bundle.path(forResource: RuntimeStringFileLocalization.shared.getCurrentLanguage(), ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }
        else if let path = bundle.path(forResource: "Base", ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }
        return self
    }
    
    func runtimeLocalizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: runtimeLocalized(), arguments: arguments)
    }
    
    func runtimeLocalizedPlural(_ argument: CVarArg) -> String {
        return NSString.localizedStringWithFormat(runtimeLocalized() as NSString, argument) as String
    }
}
