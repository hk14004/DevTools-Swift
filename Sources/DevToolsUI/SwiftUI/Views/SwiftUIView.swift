//
//  SwiftUIView.swift
//  
//
//  Created by Hardijs Ķirsis on 28/05/2023.
//

import SwiftUI
import DevToolsCore

public struct LocalizedPreview: View {
    
    public init(languageSetClosure: DevToolsCore.VoidCallback) {
        languageSetClosure()
    }
    
    public var body: some View {
        EmptyView()
    }
}
