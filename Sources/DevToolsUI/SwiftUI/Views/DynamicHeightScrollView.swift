//
//  DynamicHeightScrollView.swift
//  
//
//  Created by Hardijs Ķirsis on 25/04/2023.
//

import SwiftUI

public struct DynamicHeightScrollView<Content> : View where Content : View {
    
    public init(showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    @State private var contentSize: CGSize = .zero
    private let showsIndicators: Bool
    var content: Content
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            Group {
                content
            }
            .overlay(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        contentSize = geo.size
                    }
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: contentSize.height)
    }
}
