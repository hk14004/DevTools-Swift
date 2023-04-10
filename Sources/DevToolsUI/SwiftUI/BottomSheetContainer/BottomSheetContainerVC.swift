//
//  BottomSheetContainerVC.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import SwiftUI

public protocol BottomSheetDynamicContentViewProtocol: View {
    associatedtype vmType: BottomSheetContainerVMProtocol
    var viewModel: vmType { get }
}

public class BottomSheetContainerVC<T: View & BottomSheetDynamicContentViewProtocol>: UIHostingController<BottomSheetContainerView<T>>, UIViewControllerTransitioningDelegate {

    init(rootView: T, size: BottomSheetContainerSize) {
        super.init(rootView: BottomSheetContainerView(size: size, vm: rootView.viewModel, content: {
            rootView
        }))
        modalPresentationStyle = .custom
        view.backgroundColor = .clear
        transitioningDelegate = self
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideUpCoverBackground()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideDownCoverBackground()
    }
    
}
