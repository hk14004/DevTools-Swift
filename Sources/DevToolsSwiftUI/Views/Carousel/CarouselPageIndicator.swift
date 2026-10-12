//
//  CarouselPageIndicator.swift
//
//
//  Created by Hardijs Ķirsis on 12/10/2026.
//

import SwiftUI

/// One dot per carousel item. Tapping a dot selects that item.
struct CarouselPageIndicator: View {

    let count: Int
    let selectedIndex: Int
    let style: CarouselPageIndicatorStyle
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: style.dotSpacing) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? style.activeColor : style.inactiveColor)
                    .frame(width: style.dotSize, height: style.dotSize)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture { onSelect(index) }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        .accessibilityElement(children: .ignore)
        .accessibilityValue("\(selectedIndex + 1) / \(count)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onSelect(min(selectedIndex + 1, count - 1))
            case .decrement: onSelect(max(selectedIndex - 1, 0))
            @unknown default: break
            }
        }
    }
}
