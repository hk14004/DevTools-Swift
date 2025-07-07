//
//  RuntimeStringFileLocalization.swift
//
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import DevToolsCore
import Combine

public final class RuntimeStringFileLocalization {
    // MARK: Constant
    enum Constant {
        static let defaultLanguageCode = "en"
        static let currentLanguageKey = "RuntimeStringFileLocalizationLanguageKey"
        static let languageChangeNotification = "RuntimeStringFileLocalizationLanguageChangeNotification"
    }
    
    // MARK: Properties
    public static let shared = RuntimeStringFileLocalization()
    public var bundle: Bundle = .main
    private lazy var currentLanguagePublisher = CurrentValueSubject<String, Never>(Self.shared.getCurrentLanguage())
    
    // MARK: LifeCycle
    private init() {}
}

// MARK: Public
extension RuntimeStringFileLocalization: RuntimeLocalization {
    public func getCurrentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: Constant.currentLanguageKey) as? String {
            return currentLanguage
        }
        return Constant.defaultLanguageCode
    }
    
    public func getAvailableLanguages() -> [String] {
        var availableLanguages = bundle.localizations
        if let indexOfBase = availableLanguages.firstIndex(of: "Base") {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }
    
    public func change(languageCode: String) {
        let selectedLanguage = getAvailableLanguages().contains(languageCode) ? languageCode : Constant.defaultLanguageCode
        if (selectedLanguage != getCurrentLanguage()){
            UserDefaults.standard.set(selectedLanguage, forKey: Constant.currentLanguageKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.languageChangeNotification), object: nil)
        }
        currentLanguagePublisher.send(languageCode)
    }
    
    public func observeCurrentLanguage() -> AnyPublisher<String, Never> {
        currentLanguagePublisher.eraseToAnyPublisher()
    }
    
    public func observeLanguage(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector,
                                               name: NSNotification.Name(Constant.languageChangeNotification),
                                               object: nil)
    }
    
    public func observeLanguage(callback: @escaping ((LanguageCode) -> ())) -> ObserverHandle {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(Constant.languageChangeNotification),
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
    
    public func localized(_ string: String) -> String {
        return string.runtimeLocalized()
    }

    public func localizedFormat(_ string: String, arguments: CVarArg...) -> String {
        return String(format: string.runtimeLocalized(), arguments: arguments)
    }

    public func localizedPlural(_ string: String, argument: CVarArg) -> String {
        return string.runtimeLocalizedPlural(argument)
    }
    
    private func displayNameForLanguage(_ language: String) -> String {
        let locale : NSLocale = NSLocale(localeIdentifier: getCurrentLanguage())
        if let displayName = locale.displayName(forKey: NSLocale.Key.identifier, value: language) {
            return displayName
        }
        return String()
    }
}
