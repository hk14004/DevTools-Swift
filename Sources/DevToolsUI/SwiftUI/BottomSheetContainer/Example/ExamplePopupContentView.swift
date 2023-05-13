//
//  ExamplePopupContentVM.swift
//  
//
//  Created by Hardijs Ķirsis on 25/04/2023.
//

import SwiftUI

fileprivate struct ExamplePopupContentView: View, BottomSheetDynamicContentViewProtocol{

    var viewModel: ExamplePopupContentVM
    
    var body: some View {
        DynamicHeightScrollView {
            VStack {
                Rectangle()
                    .frame(height: 100)
                Text("Lorem ipsum")
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut non ipsum molestie, feugiat mi in, accumsan mi. Donec sit amet libero sit amet leo bibendum iaculis eu ullamcorper ligula. Etiam ante lectus, efficitur id purus vitae, facilisis sodales est. In consequat nisi eget quam aliquet, quis finibus orci facilisis. Aenean non tincidunt sem. Nullam semper est in mauris blandit, vel volutpat enim congue. Ut ut urna at purus luctus fringilla. Aenean tempor interdum tellus, a pellentesque orci venenatis et. Ut ante nisl, pharetra vitae libero id, eleifend tincidunt felis. In ac aliquam magna. Pellentesque suscipit erat ligula, at finibus nisl commodo non. Duis pretium felis nulla, sed sagittis erat lobortis sit amet. Proin rhoncus finibus lectus, in aliquam massa. Mauris felis dui, pulvinar dignissim nulla pretium, ullamcorper egestas velit.")
            }
        }
    }
}

fileprivate class ExamplePopupContentVM: BottomSheetContainerVMProtocol {
    func onTappedOutsideOfContent() {
        print("Tapped shadow")
    }
}

fileprivate extension UIViewController {
    func presentExamplePopup() {
        let vm = ExamplePopupContentVM()
        let vc = BottomSheetContainerVC(rootView: ExamplePopupContentView(viewModel: vm), size: .constant(300))
        navigationController?.present(vc, animated: true)
    }
}
