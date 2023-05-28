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
    public func getAvailable() -> [String] {
        Localize.availableLanguages(true)
    }
    
    public func change(languageCode: String) {
        Localize.setCurrentLanguage(languageCode)
    }
    
    public func observeChange(observer: Any?, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector,
                                               name: NSNotification.Name(LCLLanguageChangeNotification),
                                               object: nil)
    }
    
    public func observeChange(observer: Any?, callback: @escaping VoidCallback) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(LCLLanguageChangeNotification),
                                               object: self, queue: .main) { _ in
            callback()
        }
    }
}
