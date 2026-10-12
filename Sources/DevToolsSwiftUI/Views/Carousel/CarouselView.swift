//
//  CarouselView.swift
//
//
//  Created by Hardijs Ķirsis on 12/10/2026.
//

import SwiftUI

/// A horizontal carousel / pager that snaps the selected item to the centre.
///
/// The content closure draws the whole item — including any card background — so the
/// carousel stays agnostic about how items look. Item width is configurable, so neighbours
/// can peek in from the sides or several small items can be visible at once.
///
/// ```swift
/// @State private var selectedID: Offer.ID?
///
/// CarouselView(
///     offers,
///     selection: $selectedID,
///     itemWidth: .inset(32),
///     spacing: 8,
///     showsPageIndicator: true
/// ) { offer in
///     OfferCard(offer)
///         .frame(maxHeight: .infinity, alignment: .top) // fill the shared height
///         .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
/// }
/// ```
///
/// - Note: All items are laid out eagerly, so it's meant for tens of items, not hundreds.
///   The carousel clips its items vertically; give your content vertical padding if it
///   draws shadows.
public struct CarouselView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {

    private let data: Data
    private let externalSelection: Binding<Data.Element.ID?>?
    private let itemWidth: CarouselItemWidth
    private let spacing: CGFloat
    private let heightMode: CarouselHeightMode
    private let showsPageIndicator: Bool
    private let pageIndicatorStyle: CarouselPageIndicatorStyle
    private let content: (Data.Element) -> Content

    @State private var internalSelection: Data.Element.ID?
    @StateObject private var height = CarouselHeight()

    /// Creates a carousel whose current item is bound to `selection`.
    ///
    /// Swiping updates `selection`; setting it scrolls to that item. A `nil` selection
    /// shows the first item.
    public init(
        _ data: Data,
        selection: Binding<Data.Element.ID?>,
        itemWidth: CarouselItemWidth = .full,
        spacing: CGFloat = 8,
        heightMode: CarouselHeightMode = .equal,
        showsPageIndicator: Bool = false,
        pageIndicatorStyle: CarouselPageIndicatorStyle = .default,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.externalSelection = selection
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.heightMode = heightMode
        self.showsPageIndicator = showsPageIndicator
        self.pageIndicatorStyle = pageIndicatorStyle
        self.content = content
    }

    /// Creates a carousel that tracks its current item internally.
    public init(
        _ data: Data,
        itemWidth: CarouselItemWidth = .full,
        spacing: CGFloat = 8,
        heightMode: CarouselHeightMode = .equal,
        showsPageIndicator: Bool = false,
        pageIndicatorStyle: CarouselPageIndicatorStyle = .default,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.externalSelection = nil
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.heightMode = heightMode
        self.showsPageIndicator = showsPageIndicator
        self.pageIndicatorStyle = pageIndicatorStyle
        self.content = content
    }

    public var body: some View {
        VStack(spacing: pageIndicatorStyle.spacing) {
            CarouselHeightFrame(height: height) {
                CarouselScrollView(
                    data: data,
                    itemWidth: itemWidth,
                    spacing: spacing,
                    heightMode: heightMode,
                    selection: selection,
                    onHeightChange: { [height] in height.value = $0 },
                    content: content
                )
            }

            if showsPageIndicator && data.count > 1 {
                CarouselPageIndicator(
                    count: data.count,
                    selectedIndex: selectedIndex,
                    style: pageIndicatorStyle,
                    onSelect: { index in
                        selection.wrappedValue = data[data.index(data.startIndex, offsetBy: index)].id
                    }
                )
            }
        }
    }

    private var selection: Binding<Data.Element.ID?> {
        externalSelection ?? $internalSelection
    }

    private var selectedIndex: Int {
        guard let id = selection.wrappedValue else { return 0 }
        return data.enumerated().first { $0.element.id == id }?.offset ?? 0
    }
}

// MARK: - Height

/// The carousel's measured height. It lives in an object, not `@State`, so that the
/// per-frame changes of `.fitSelected` only re-render `CarouselHeightFrame` and not
/// `CarouselView` itself (which would rebuild every item each frame).
final class CarouselHeight: ObservableObject {
    @Published var value: CGFloat = .zero
}

private struct CarouselHeightFrame<Content: View>: View {
    @ObservedObject var height: CarouselHeight
    @ViewBuilder let content: Content

    var body: some View {
        content.frame(height: height.value)
    }
}

// MARK: - Options

/// How wide each carousel item is, relative to the carousel's own width.
public enum CarouselItemWidth: Equatable {
    /// The item fills the carousel's width.
    case full
    /// The item is the carousel's width minus this inset on each side, so neighbours peek in.
    case inset(CGFloat)
    /// A fixed width. When it's small, several items are visible at once.
    case fixed(CGFloat)
    /// A fraction of the carousel's width, from `0` to `1`.
    case fractional(CGFloat)

    func resolved(in containerWidth: CGFloat) -> CGFloat {
        let width: CGFloat
        switch self {
        case .full: width = containerWidth
        case .inset(let inset): width = containerWidth - inset * 2
        case .fixed(let fixed): width = fixed
        case .fractional(let fraction): width = containerWidth * fraction
        }
        return min(max(width, 0), containerWidth)
    }
}

/// How item heights relate to each other, and how tall the carousel is.
public enum CarouselHeightMode: Equatable {
    /// Every item is stretched to the tallest item's height, which is also the carousel's height.
    ///
    /// To make a card's background fill that height, apply `.frame(maxHeight: .infinity)`
    /// to the card content before its background.
    case equal
    /// Every item keeps its own height and is aligned within the carousel, which is as tall
    /// as the tallest item. Content below the carousel doesn't move.
    case intrinsic(alignment: VerticalAlignment)
    /// The carousel takes the selected item's height, and resizes while you swipe so
    /// content below it moves with the finger. Items are top aligned; taller neighbours
    /// are clipped at the carousel's current height.
    case fitSelected
}

/// The look of the page indicator dots shown below the carousel.
public struct CarouselPageIndicatorStyle {
    public var activeColor: Color
    public var inactiveColor: Color
    public var dotSize: CGFloat
    public var dotSpacing: CGFloat
    /// The gap between the carousel and the dots.
    public var spacing: CGFloat

    public init(
        active activeColor: Color = .primary,
        inactive inactiveColor: Color = .secondary.opacity(0.3),
        dotSize: CGFloat = 8,
        dotSpacing: CGFloat = 8,
        spacing: CGFloat = 8
    ) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.dotSize = dotSize
        self.dotSpacing = dotSpacing
        self.spacing = spacing
    }

    public static let `default` = CarouselPageIndicatorStyle()
}
