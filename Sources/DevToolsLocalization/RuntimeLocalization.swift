//
//  RuntimeLanguageInterface.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import DevToolsCore
import Combine

public typealias LanguageCode = String
public typealias ObserverHandle = NSObjectProtocol

public protocol RuntimeLocalization {
    func getCurrentLanguage() -> String
    func getAvailableLanguages() -> [String]
    @MainActor func change(languageCode: String)
    func observeCurrentLanguage() -> AnyPublisher<LanguageCode, Never>
    @available(*, deprecated, message: "Use observeCurrentLanguage() and store the returned AnyCancellable instead.")
    func observeLanguage(observer: Any, selector: Selector)
    @available(*, deprecated, message: "Use observeCurrentLanguage() and store the returned AnyCancellable instead.")
    func observeLanguage(callback: @escaping ((LanguageCode) -> ())) -> ObserverHandle
    @available(*, deprecated, message: "Cancel the AnyCancellable returned by observeCurrentLanguage() instead.")
    func stopObservingLanguage(handle: ObserverHandle)
    @available(*, deprecated, message: "Cancel the AnyCancellable returned by observeCurrentLanguage() instead.")
    func stopObservingLanguage(observer: Any)
    func localized(_ string: String) -> String
    func localizedFormat(_ string: String, arguments: CVarArg...) -> String
    func localizedPlural(_ string: String, argument: CVarArg) -> String
    /// Returns the localised display name for a language code in the currently active language.
    /// Use this to populate a language picker with human-readable names.
    /// Example: passing `"fr"` while the current language is `"en"` returns `"French"`.
    func displayName(for languageCode: String) -> String
}
