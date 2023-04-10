//
//  File.swift
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
    public let content: () -> Content
    public let viewModel: BottomSheetContainerVMProtocol

    // MARK: Init
    
    public init(size: BottomSheetContainerSize, vm: BottomSheetContainerVMProtocol, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.size = size
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
            VStack(spacing: 0) {
                content()
            }
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) // Respect the bottom safe area for the child view
            .sizeModifier(size: size)
            .background(Color.red)
            .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
        }
        .edgesIgnoringSafeArea(.bottom)
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
