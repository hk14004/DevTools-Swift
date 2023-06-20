//
//  RuntimeLanguageInterface.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import Localize_Swift
import DevToolsCore

public typealias LanguageCode = String
public typealias ObserverHandle = NSObjectProtocol

public protocol RuntimeLocalization {
    func getCurrentLanguage() -> String
    func getAvailableLanguages() -> [String]
    func change(languageCode: String)
    func observeLanguage(observer: Any, selector: Selector)
    func observeLanguage(observer: Any, callback: @escaping ((LanguageCode) -> ())) -> ObserverHandle
}
