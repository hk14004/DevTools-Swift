//
//  String + Localized.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation

// Overrided dependency access

public extension String {
    /**
     Swift 2 friendly localization syntax, replaces NSLocalizedString
     - Returns: The localized string.
     */
    func localized() -> String {
        return localized(using: nil, in: .main)
    }

    /**
     Swift 2 friendly localization syntax with format arguments, replaces String(format:NSLocalizedString)
     - Returns: The formatted localized string with arguments.
     */
    func localizedFormat(_ arguments: CVarArg...) -> String {
        return String(format: localized(), arguments: arguments)
    }
    
    /**
     Swift 2 friendly plural localization syntax with a format argument
     
     - parameter argument: Argument to determine pluralisation
     
     - returns: Pluralized localized string.
     */
    func localizedPlural(_ argument: CVarArg) -> String {
        return NSString.localizedStringWithFormat(localized() as NSString, argument) as String
    }

    /**
     Add comment for NSLocalizedString
     - Returns: The localized string.
    */
    func commented(_ argument: String) -> String {
        return self
    }
}
