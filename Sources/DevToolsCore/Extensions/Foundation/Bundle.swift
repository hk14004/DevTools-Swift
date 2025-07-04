//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 16/09/2023.
//

import Foundation

public extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
