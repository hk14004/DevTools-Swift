//
//  String + RuntimeLocalized.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import Foundation
import SwiftUI

public extension String {
    func runtimeLocalized() -> String {
        localized(using: nil, in: RuntimeStringFileLocalization.shared.bundle)
    }
}
