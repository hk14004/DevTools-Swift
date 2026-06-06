//
//  DynamicHeightScrollView.swift
//
//
//  Created by Hardijs Ķirsis on 25/04/2023.
//

import SwiftUI

/// A scroll view that sizes itself to match its content height.
///
/// Unlike a fixed-frame scroll view, this expands or contracts as content changes —
/// useful inside a `VStack` or a parent scroll view where you want the content
/// to take only as much space as it needs.
///
/// ```swift
/// DynamicHeightScrollView {
///     VStack {
///         ForEach(items) { item in
///             Text(item.title)
///         }
///     }
/// }
/// ```
public struct DynamicHeightScrollView<Content: View>: View {

    private let showsIndicators: Bool
    private let content: Content

    @State private var contentHeight: CGFloat = .zero

    public init(showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            content
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ContentHeightKey.self, value: geo.size.height)
                    }
                )
        }
        .onPreferenceChange(ContentHeightKey.self) { height in
            contentHeight = height
        }
        .frame(maxWidth: .infinity, maxHeight: contentHeight)
    }
}

// MARK: - PreferenceKey

private struct ContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
