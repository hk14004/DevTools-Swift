//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import UIKit

public class SlideDownCoverBackground: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval = 0.35

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
            
            guard let fromView = transitionContext.view(forKey: .from) else { return }
            
            // Darkview
            guard let darkView = containerView.subviews.last(where: { $0.backgroundColor == UIColor(white: 0, alpha: 0.5) }) else { return }
            
            let finalFrame = CGRect(x: 0, y: containerView.bounds.maxY, width: containerView.bounds.width, height: containerView.bounds.height)
            
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
                darkView.alpha = 0
                fromView.frame = finalFrame
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
    }
}
