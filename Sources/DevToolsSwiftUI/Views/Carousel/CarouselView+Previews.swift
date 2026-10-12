//
//  CarouselView+Previews.swift
//
//
//  Created by Hardijs Ķirsis on 12/10/2026.
//

#if DEBUG
import SwiftUI

// MARK: - Showcase

/// Every main `CarouselView` configuration on one scrollable page, each labelled with
/// the options that produce it.
struct CarouselShowcase: View {

    @State var rightToLeft = false
    @State private var selection: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Button(rightToLeft ? "Right-to-left: on" : "Right-to-left: off") {
                    rightToLeft.toggle()
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)

                _ShowcaseSection("Full width", code: "itemWidth: .full  // default") {
                    CarouselView(_previewItems, showsPageIndicator: true) { _PreviewCard(item: $0) }
                }

                _ShowcaseSection("Peeking neighbours", code: "itemWidth: .inset(32), spacing: 8") {
                    CarouselView(_previewItems, itemWidth: .inset(32), spacing: 8, showsPageIndicator: true) {
                        _PreviewCard(item: $0)
                    }
                }

                _ShowcaseSection("Fraction of the width", code: "itemWidth: .fractional(0.6)") {
                    CarouselView(_previewItems, itemWidth: .fractional(0.6), showsPageIndicator: true) {
                        _PreviewCard(item: $0)
                    }
                }

                _ShowcaseSection("Several visible at once", code: "itemWidth: .fixed(100)") {
                    CarouselView(_previewTiles, itemWidth: .fixed(100), showsPageIndicator: true) { _PreviewTile(item: $0) }
                }

                _ShowcaseSection("Equal heights", code: "heightMode: .equal  // default") {
                    CarouselView(_previewItems, itemWidth: .inset(32), heightMode: .equal, showsPageIndicator: true) {
                        _PreviewCard(item: $0)
                    }
                    _ContentBelow()
                }

                _ShowcaseSection("Intrinsic heights", code: "heightMode: .intrinsic(alignment: .top)") {
                    CarouselView(_previewItems, itemWidth: .inset(32), heightMode: .intrinsic(alignment: .top), showsPageIndicator: true) {
                        _PreviewCard(item: $0)
                    }
                    _ContentBelow()
                }

                _ShowcaseSection("Fit selected item", code: "heightMode: .fitSelected") {
                    CarouselView(_previewItems, itemWidth: .inset(32), heightMode: .fitSelected, showsPageIndicator: true) {
                        _PreviewCard(item: $0)
                    }
                    _ContentBelow()
                }

                _ShowcaseSection("Selection binding", code: "selection: $selection") {
                    CarouselView(_previewItems, selection: $selection, itemWidth: .inset(32)) { _PreviewCard(item: $0) }
                    HStack {
                        Button("Previous") { selection = max((selection ?? 0) - 1, 0) }
                        Spacer()
                        Text("selection: \(selection.map(String.init) ?? "nil")").font(.callout.monospaced())
                        Spacer()
                        Button("Next") { selection = min((selection ?? 0) + 1, _previewItems.count - 1) }
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }

                _ShowcaseSection(
                    "Custom page dots",
                    code: "pageIndicatorStyle: .init(active: .orange, inactive: .orange.opacity(0.25), dotSize: 6)"
                ) {
                    CarouselView(
                        _previewItems,
                        itemWidth: .inset(32),
                        showsPageIndicator: true,
                        pageIndicatorStyle: .init(active: .orange, inactive: .orange.opacity(0.25), dotSize: 6, dotSpacing: 6, spacing: 12)
                    ) {
                        _PreviewCard(item: $0)
                    }
                }
            }
            .padding(.vertical)
        }
        .environment(\.layoutDirection, rightToLeft ? .rightToLeft : .leftToRight)
    }
}

private struct _ShowcaseSection<Content: View>: View {
    let title: String
    let code: String
    let content: Content

    init(_ title: String, code: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.code = code
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.title3.bold())
                Text(code).font(.caption.monospaced()).foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            content
        }
    }
}

// MARK: - Preview data

private struct _PreviewItem: Identifiable {
    let id: Int
    let title: String
    let body: String
    let color: Color
}

/// Heights differ a lot on purpose — "Offers" is about twice as tall as the others — so
/// the difference between the height modes is easy to see.
private let _previewItems: [_PreviewItem] = [
    _PreviewItem(id: 0, title: "Welcome", body: "A short card.", color: .blue),
    _PreviewItem(
        id: 1,
        title: "Offers",
        body: "This card has a much longer body. It wraps onto several lines, which makes it roughly twice as tall as the others, so you can see how each height mode handles the difference. Swipe back and forth and watch the content below the carousel.",
        color: .orange
    ),
    _PreviewItem(id: 2, title: "Rewards", body: "A medium length body that wraps onto a second line.", color: .green),
    _PreviewItem(id: 3, title: "Settings", body: "Another short one.", color: .purple),
    _PreviewItem(id: 4, title: "Help", body: "The last card in the deck.", color: .pink),
]

private let _previewTiles = (0..<12).map { _PreviewItem(id: $0, title: "\($0 + 1)", body: "", color: .teal) }

private struct _PreviewCard: View {
    let item: _PreviewItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title).font(.headline)
            Text(item.body).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding()
        // Fills the slot in `.equal` mode; the other modes keep each card at its own height.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(item.color.opacity(0.2), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct _PreviewTile: View {
    let item: _PreviewItem

    var body: some View {
        Text(item.title)
            .font(.title.bold())
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(item.color.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
    }
}

/// Stand-in for whatever sits under a carousel, to show whether it moves.
private struct _ContentBelow: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15 + Double(index) * 0.08))
                    .frame(height: 44)
            }
        }
        .overlay(Text("Content below").font(.caption).foregroundStyle(.secondary))
        .padding(.horizontal)
    }
}

// MARK: - Previews

#Preview("Showcase") {
    CarouselShowcase()
}

#Preview("Fit selected item") {
    VStack(spacing: 16) {
        CarouselView(_previewItems, itemWidth: .inset(32), heightMode: .fitSelected, showsPageIndicator: true) {
            _PreviewCard(item: $0)
        }
        _ContentBelow()
        Spacer()
    }
}

#Preview("Right-to-left") {
    CarouselShowcase(rightToLeft: true)
}
#endif
