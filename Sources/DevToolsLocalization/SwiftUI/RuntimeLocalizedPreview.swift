//
//  RuntimeLocalizedPreview.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import SwiftUI

public struct RuntimeLocalizedPreview: View {
    
    public init(language: String) {
        RuntimeLocalization.shared.change(languageCode: language)
    }
    
    public var body: some View {
        EmptyView()
    }
    
}
