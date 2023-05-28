//
//  RuntimeLocalizationObserver.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import SwiftUI

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
