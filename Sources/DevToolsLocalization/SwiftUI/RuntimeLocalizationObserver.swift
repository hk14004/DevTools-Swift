//
//  RuntimeLocalizationObserver.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import SwiftUI

public final class RuntimeLocalizationObserver: ObservableObject {

    private let animate: Bool
    
    public init(animate: Bool = true) {
        self.animate = animate
        RuntimeStringFileLocalization.shared.observeLanguage(observer: self, selector: #selector(onLanguageChanged))
    }
    
    deinit {
        RuntimeStringFileLocalization.shared.stopObservingLanguage(observer: self)
    }
    
    @objc private func onLanguageChanged() {
        func updateUI() {
            objectWillChange.send()
        }
        if animate {
            withAnimation {
                updateUI()
            }
        } else {
            updateUI()
        }
    }
}
