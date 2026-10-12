//
//  CarouselScrollView.swift
//
//
//  Created by Hardijs Ķirsis on 12/10/2026.
//

import SwiftUI
import UIKit

/// The scrolling part of `CarouselView`.
///
/// iOS 16 has no SwiftUI API for snapping or a two-way scroll position, and a SwiftUI
/// `DragGesture` fights a parent vertical `ScrollView`. So a `UIScrollView` provides the
/// scroll physics and snapping, while the items themselves are laid out by a SwiftUI
/// `HStack` hosted inside it.
///
/// Item `i` sits centred when `contentOffset.x == i * (itemWidth + spacing)` — the
/// horizontal padding on the row is what makes that hold for the first and last item.
struct CarouselScrollView<Data: RandomAccessCollection, Content: View>: UIViewRepresentable where Data.Element: Identifiable {

    let data: Data
    let itemWidth: CarouselItemWidth
    let spacing: CGFloat
    let heightMode: CarouselHeightMode
    @Binding var selection: Data.Element.ID?
    let onHeightChange: (CGFloat) -> Void
    let content: (Data.Element) -> Content

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> CarouselUIScrollView {
        let scrollView = CarouselUIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast
        scrollView.backgroundColor = .clear
        scrollView.delegate = context.coordinator

        let coordinator = context.coordinator
        scrollView.addSubview(coordinator.host.view)
        scrollView.onSizeChange = { [unowned coordinator] widthChanged in
            coordinator.containerSizeDidChange(widthChanged: widthChanged)
        }
        scrollView.onAccessibilityScroll = { [unowned coordinator] direction in
            coordinator.handleAccessibilityScroll(direction)
        }
        coordinator.scrollView = scrollView
        return scrollView
    }

    func updateUIView(_ scrollView: CarouselUIScrollView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.update(environment: context.environment)
    }
}

// MARK: - Coordinator

extension CarouselScrollView {

    final class Coordinator: NSObject, UIScrollViewDelegate {

        var parent: CarouselScrollView
        weak var scrollView: CarouselUIScrollView?
        let host: UIHostingController<CarouselRow<Data.Element, Content>>

        private var items: [Data.Element] = []
        private var environment = EnvironmentValues()
        private var metrics = CarouselMetrics(containerWidth: 0, itemWidth: .full, spacing: 0)
        private var currentIndex = 0
        private var dragStartIndex = 0
        private var rowHeight: CGFloat = 0
        private var itemHeights: [Int: CGFloat] = [:]
        private var reportedHeight: CGFloat = -1

        private var isRightToLeft: Bool { environment.layoutDirection == .rightToLeft }

        init(parent: CarouselScrollView) {
            self.parent = parent
            self.host = UIHostingController(rootView: CarouselRow(
                items: [],
                metrics: metrics,
                heightMode: parent.heightMode,
                environment: environment,
                onRowHeightChange: { _ in },
                onItemHeightsChange: { _ in },
                content: parent.content
            ))
            super.init()
            host.view.backgroundColor = .clear
            if #available(iOS 16.4, *) {
                host.safeAreaRegions = []
            }
        }

        // MARK: Updates from SwiftUI

        func update(environment: EnvironmentValues) {
            let directionChanged = environment.layoutDirection != self.environment.layoutDirection
            let countChanged = parent.data.count != items.count
            self.environment = environment
            items = Array(parent.data)
            render()

            let target = selectionIndex()
            if target != currentIndex {
                currentIndex = target
                if scrollView?.isDragging == false {
                    scroll(to: target, animated: scrollView?.window != nil)
                }
            } else if directionChanged || countChanged {
                scroll(to: currentIndex, animated: false)
            }
            updateHeight()
        }

        /// Only a width change matters: the hosted row's height doesn't depend on the
        /// scroll view's, which changes every frame in `.fitSelected` mode.
        func containerSizeDidChange(widthChanged: Bool) {
            guard widthChanged else { return }
            render()
            scroll(to: currentIndex, animated: false)
            updateHeight()
        }

        private func render() {
            guard let scrollView else { return }
            metrics = CarouselMetrics(
                containerWidth: scrollView.bounds.width,
                itemWidth: parent.itemWidth,
                spacing: parent.spacing
            )
            currentIndex = clamped(currentIndex)
            host.rootView = CarouselRow(
                items: items,
                metrics: metrics,
                heightMode: parent.heightMode,
                environment: environment,
                onRowHeightChange: { [weak self] height in
                    self?.rowHeight = height
                    self?.layoutHost()
                    self?.updateHeight()
                },
                onItemHeightsChange: { [weak self] heights in
                    self?.itemHeights = heights
                    self?.updateHeight()
                },
                content: parent.content
            )
            layoutHost()
        }

        /// Sizes the hosted row to the tallest item. In `.fitSelected` mode the scroll view
        /// is shorter than that and clips the taller items.
        private func layoutHost() {
            guard let scrollView else { return }
            let width = metrics.contentWidth(count: items.count)
            let size = CGSize(width: width, height: rowHeight)
            // Only touch the geometry when it changes, so a selection write-back mid-fling
            // doesn't disturb the deceleration.
            guard host.view.frame.size != size else { return }
            host.view.frame = CGRect(origin: .zero, size: size)
            scrollView.contentSize = CGSize(width: width, height: 0)
        }

        /// Reports the carousel's height to `CarouselView`. In `.fitSelected` mode it blends
        /// between the two items either side of the current scroll position, so the
        /// carousel resizes as the finger moves.
        private func updateHeight() {
            var height = rowHeight
            if parent.heightMode == .fitSelected, !items.isEmpty, metrics.page > 0, let scrollView {
                let last = CGFloat(items.count - 1)
                var position = min(max(scrollView.contentOffset.x / metrics.page, 0), last)
                if isRightToLeft { position = last - position }
                let lower = Int(position.rounded(.down))
                let upper = min(lower + 1, items.count - 1)
                let lowerHeight = itemHeights[lower] ?? rowHeight
                let upperHeight = itemHeights[upper] ?? rowHeight
                height = lowerHeight + (upperHeight - lowerHeight) * (position - CGFloat(lower))
            }
            guard abs(height - reportedHeight) > 0.25 else { return }
            reportedHeight = height
            parent.onHeightChange(height)
        }

        /// The index the selection points at. `nil` means the first item; an unknown ID keeps the current item.
        private func selectionIndex() -> Int {
            guard let id = parent.selection else { return 0 }
            return items.firstIndex { $0.id == id } ?? currentIndex
        }

        // MARK: Scrolling

        private func offset(for index: Int) -> CGFloat {
            let position = isRightToLeft ? items.count - 1 - index : index
            return CGFloat(position) * metrics.page
        }

        private func index(for offset: CGFloat) -> Int {
            guard metrics.page > 0, !items.isEmpty else { return 0 }
            let position = clamped(Int((offset / metrics.page).rounded()))
            return isRightToLeft ? items.count - 1 - position : position
        }

        private func clamped(_ index: Int) -> Int {
            min(max(index, 0), max(items.count - 1, 0))
        }

        private func scroll(to index: Int, animated: Bool) {
            guard let scrollView, scrollView.bounds.width > 0 else { return }
            scrollView.setContentOffset(CGPoint(x: offset(for: index), y: 0), animated: animated)
        }

        /// Records the item the user scrolled to and writes it back to the selection.
        private func report(_ index: Int) {
            currentIndex = index
            guard items.indices.contains(index) else { return }
            let id = items[index].id
            if parent.selection != id {
                parent.selection = id
            }
        }

        // MARK: UIScrollViewDelegate

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if parent.heightMode == .fitSelected {
                updateHeight()
            }
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            dragStartIndex = index(for: scrollView.contentOffset.x)
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            guard metrics.page > 0, !items.isEmpty else { return }

            // Positive means towards higher indices.
            let forwardVelocity = isRightToLeft ? -velocity.x : velocity.x
            var target = index(for: targetContentOffset.pointee.x)
            if forwardVelocity > 0.2 {
                target = max(target, dragStartIndex + 1)
            } else if forwardVelocity < -0.2 {
                target = min(target, dragStartIndex - 1)
            }

            // A fling moves at most one screenful: one item when items are full width,
            // several when they're small.
            let maxJump = max(1, Int((metrics.containerWidth + metrics.spacing) / metrics.page))
            target = min(max(target, dragStartIndex - maxJump), dragStartIndex + maxJump)
            target = clamped(target)

            let x = offset(for: target)
            if velocity.x == 0 {
                // With no velocity UIKit jumps to a changed target instead of animating to it.
                targetContentOffset.pointee = scrollView.contentOffset
                DispatchQueue.main.async {
                    scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
                }
            } else {
                targetContentOffset.pointee.x = x
            }
            report(target)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            settle(scrollView)
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            settle(scrollView)
        }

        /// Snaps to the nearest item after a scroll the carousel didn't drive, e.g. VoiceOver
        /// scrolling a focused item into view.
        private func settle(_ scrollView: UIScrollView) {
            guard !scrollView.isDragging else { return }
            let nearest = index(for: scrollView.contentOffset.x)
            if abs(scrollView.contentOffset.x - offset(for: nearest)) > 0.5 {
                scroll(to: nearest, animated: true)
            }
            report(nearest)
        }

        // MARK: Accessibility

        func handleAccessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
            let forward: Bool
            switch direction {
            case .left: forward = !isRightToLeft
            case .right: forward = isRightToLeft
            case .next: forward = true
            case .previous: forward = false
            default: return false
            }
            let target = clamped(currentIndex + (forward ? 1 : -1))
            guard target != currentIndex else { return false }
            scroll(to: target, animated: true)
            report(target)
            UIAccessibility.post(notification: .pageScrolled, argument: "\(target + 1) / \(items.count)")
            return true
        }
    }
}

// MARK: - Metrics

struct CarouselMetrics: Equatable {

    let containerWidth: CGFloat
    let itemWidth: CGFloat
    let spacing: CGFloat

    init(containerWidth: CGFloat, itemWidth: CarouselItemWidth, spacing: CGFloat) {
        self.containerWidth = containerWidth
        self.itemWidth = itemWidth.resolved(in: containerWidth)
        self.spacing = spacing
    }

    /// The distance between the leading edges of two neighbouring items.
    var page: CGFloat { itemWidth + spacing }

    /// Padding on each side of the row, so the first and last item can be centred.
    var sideMargin: CGFloat { (containerWidth - itemWidth) / 2 }

    func contentWidth(count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        return sideMargin * 2 + CGFloat(count) * itemWidth + CGFloat(count - 1) * spacing
    }
}

// MARK: - Row

/// The SwiftUI row hosted inside the scroll view.
struct CarouselRow<Item: Identifiable, Content: View>: View {

    let items: [Item]
    let metrics: CarouselMetrics
    let heightMode: CarouselHeightMode
    /// The environment around `CarouselView`. The hosting controller starts a fresh
    /// environment, so this carries fonts, tint, environment objects etc. into the items.
    let environment: EnvironmentValues
    let onRowHeightChange: (CGFloat) -> Void
    /// Each item's own height, by index. Only `.fitSelected` uses it.
    let onItemHeightsChange: ([Int: CGFloat]) -> Void
    let content: (Item) -> Content

    var body: some View {
        HStack(alignment: alignment, spacing: metrics.spacing) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .frame(width: metrics.itemWidth)
                    // Outside `.equal`, pin each item to its own height so content that
                    // uses `.frame(maxHeight: .infinity)` doesn't stretch to the row.
                    .fixedSize(horizontal: false, vertical: heightMode != .equal)
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(key: ItemHeightsKey.self, value: [index: geo.size.height])
                        }
                    )
                    .frame(maxHeight: heightMode == .equal ? .infinity : nil)
            }
        }
        .padding(.horizontal, metrics.sideMargin)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: RowHeightKey.self, value: geo.size.height)
            }
        )
        .onPreferenceChange(RowHeightKey.self, perform: onRowHeightChange)
        .onPreferenceChange(ItemHeightsKey.self, perform: onItemHeightsChange)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .environment(\.self, environment)
    }

    private var alignment: VerticalAlignment {
        switch heightMode {
        case .equal: return .center
        case .intrinsic(let alignment): return alignment
        case .fitSelected: return .top
        }
    }
}

private struct ItemHeightsKey: PreferenceKey {
    static let defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

private struct RowHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - UIScrollView

final class CarouselUIScrollView: UIScrollView {

    var onSizeChange: ((_ widthChanged: Bool) -> Void)?
    var onAccessibilityScroll: ((UIAccessibilityScrollDirection) -> Bool)?

    private var lastSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastSize else { return }
        let widthChanged = bounds.width != lastSize.width
        lastSize = bounds.size
        onSizeChange?(widthChanged)
    }

    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        onAccessibilityScroll?(direction) ?? super.accessibilityScroll(direction)
    }
}
