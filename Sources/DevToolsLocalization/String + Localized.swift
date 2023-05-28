//
//  String + Localized.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import SwiftUI

public enum TranslationSource {
    case plist
    case stringsFile
}

public extension String {
    func stringFileLocalizable() -> LocalizedStringKey {
        .init(self)
    }
}

public extension String {

    func translate(source: TranslationSource = .stringsFile) -> LocalizedStringKey {
        return localized(using: nil, in: .main).stringFileLocalizable()
    }

}
