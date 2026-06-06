//
//  BottomSheetContainerView.swift
//
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import SwiftUI

public enum BottomSheetContainerSize {
    case wrapContent
    case constant(CGFloat)
}

public protocol BottomSheetContainerVMProtocol {
    func onTappedOutsideOfContent()
}

public struct BottomSheetContainerView<Content: View>: View {

    // MARK: Properties

    public let cornerRadius: CGFloat = 16
    public let size: BottomSheetContainerSize
    public let backgroundColor: Color
    public let content: () -> Content
    public let viewModel: BottomSheetContainerVMProtocol

    // MARK: Init

    public init(
        size: BottomSheetContainerSize,
        backgroundColor: Color = Color(.systemBackground),
        vm: BottomSheetContainerVMProtocol,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.size = size
        self.backgroundColor = backgroundColor
        self.viewModel = vm
    }

    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Spacer()
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.onTappedOutsideOfContent()
                    }
            }
            Group {
                content()
            }
            .padding(.bottom, bottomSafeAreaInset)
            .sizeModifier(size: size)
            .background(backgroundColor)
            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
            .layoutPriority(1)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    // MARK: Private

    private var bottomSafeAreaInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

fileprivate extension View {
    @ViewBuilder
    func sizeModifier(size: BottomSheetContainerSize) -> some View {
        Group {
            switch size {
            case .wrapContent:
                self.frame(maxWidth: .infinity)
            case .constant(let size):
                self.frame(maxWidth: .infinity).frame(height: size)
            }
        }
    }
}
