//
//  RuntimeLocalization.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import Localize_Swift
import DevToolsCore

public final class RuntimeLocalization {
    public static let shared = RuntimeLocalization()
}

// MARK: Public

extension RuntimeLocalization: RuntimeLanguageInterface {
    public func getCurrentLanguage() -> String {
        Localize.currentLanguage()
    }
    
    public func getAvailableLanguages() -> [String] {
        Localize.availableLanguages(true)
    }
    
    public func change(languageCode: String) {
        Localize.setCurrentLanguage(languageCode)
    }
    
    public func observeLanguage(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector,
                                               name: NSNotification.Name(LCLLanguageChangeNotification),
                                               object: nil)
    }
    
    public func observeLanguage(callback: @escaping VoidCallback) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(LCLLanguageChangeNotification),
                                               object: nil, queue: .main) { _ in
            callback()
        }
    }
}
