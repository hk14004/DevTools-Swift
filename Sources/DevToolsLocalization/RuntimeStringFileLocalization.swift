//
//  RuntimeLocalization.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import Localize_Swift
import DevToolsCore

public final class RuntimeStringFileLocalization {
    public static let shared = RuntimeStringFileLocalization()
}

// MARK: Public

extension RuntimeStringFileLocalization: RuntimeLocalization {
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
    
    public func observeLanguage(observer: Any, callback: @escaping ((LanguageCode) -> ())) -> ObserverHandle {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(LCLLanguageChangeNotification),
                                               object: observer, queue: .main) { _ in
            callback(Self.shared.getCurrentLanguage())
        }
    }
    
    public func stopObservingLanguage(handle: ObserverHandle) {
        NotificationCenter.default.removeObserver(handle)
    }
    
    public func stopObservingLanguage(observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }

}
