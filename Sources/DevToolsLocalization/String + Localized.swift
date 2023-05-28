//
//  String + Localized.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import SwiftUI


public extension String {

    func toRuntimeLocalized() -> LocalizedRuntimeText {
        .init(key: LocalizedStringKey(self), localizedString: self.localized())
    }
}

public struct LocalizedRuntimeText {
    public let key: LocalizedStringKey
    public let localizedString: String
}

public class RuntimeLocalizationObserver: ObservableObject {
    init() {
        RuntimeLocalization.shared.observeLanguage { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}
