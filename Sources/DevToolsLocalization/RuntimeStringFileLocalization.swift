//
//  RuntimeLocalization.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import Localize_Swift
import DevToolsCore
import Combine

public final class RuntimeStringFileLocalization {
    public static let shared = RuntimeStringFileLocalization()
    private let currentLanguagePublisher: CurrentValueSubject<String, Never>
    
    private init() {
        self.currentLanguagePublisher = .init(Localize.currentLanguage())
    }
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
        currentLanguagePublisher.send(languageCode)
    }
    
    public func observeCurrentLanguage() -> AnyPublisher<String, Never> {
        currentLanguagePublisher.eraseToAnyPublisher()
    }
    
    public func observeLanguage(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector,
                                               name: NSNotification.Name(LCLLanguageChangeNotification),
                                               object: nil)
    }
    
    public func observeLanguage(callback: @escaping ((LanguageCode) -> ())) -> ObserverHandle {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(LCLLanguageChangeNotification),
                                               object: nil, queue: .main) { _ in
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
