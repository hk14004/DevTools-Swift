//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import UIKit

class SlideUpCoverBackground: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: Properties
    
    let duration: TimeInterval = 0.35

    // MARK: Methods
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        // Darkview
        let darkView = UIView(frame: containerView.bounds)
        darkView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        darkView.alpha = 0
        containerView.addSubview(darkView)
        
        // Set initial frame offscreen, below the bottom of the container view
        let offscreenFrame = CGRect(x: 0, y: containerView.bounds.maxY,
                                    width: containerView.bounds.width,
                                    height: containerView.bounds.height)
        toView.frame = offscreenFrame
        
        containerView.addSubview(toView)
        
        let finalFrame = containerView.bounds
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
            darkView.alpha = 1
            toView.frame = finalFrame
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
}
