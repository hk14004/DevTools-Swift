//
//  String + Localized.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import SwiftUI


public extension String {
    func localizedRuntimeText() -> LocalizedRuntimeText {
        .init(key: LocalizedStringKey(self), localizedString: self.localized())
    }
}

public struct LocalizedRuntimeText {
    public let key: LocalizedStringKey
    public let localizedString: String
}

public final class RuntimeLocalizationObserver: ObservableObject {

    public init() {
        RuntimeLocalization.shared.observeLanguage(observer: self, selector: #selector(onLanguageChanged))
    }
    
    deinit {
        RuntimeLocalization.shared.stopObservingLanguage(observer: self)
    }
    
    @objc private func onLanguageChanged() {
        objectWillChange.send()
    }
}
