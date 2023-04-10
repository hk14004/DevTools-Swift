//
//  File.swift
//  
//
//  Created by Hardijs Ķirsis on 10/04/2023.
//

import UIKit

class SlideUpTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let onDarkBackgroundTap: ()->()
    let duration: Double
    
    init(onDarkBackgroundTap: @escaping () -> Void, duration: Double = 0.3) {
        self.onDarkBackgroundTap = onDarkBackgroundTap
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = CGRect(x: 0, y: containerView.bounds.height, width: finalFrame.width, height: finalFrame.height)
        
        let overlayView = UIView(frame: containerView.bounds)
        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        overlayView.alpha = 0
        containerView.addSubview(overlayView)
        
        containerView.addSubview(toVC.view)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
            toVC.view.frame = finalFrame
            overlayView.alpha = 1
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
    }
    
    @objc private func dismiss() {
        onDarkBackgroundTap()
    }
}

extension SlideUpTransition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideUpTransition(onDarkBackgroundTap: {presented.dismiss(animated: true)})
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideUpTransition(onDarkBackgroundTap: {dismissed.dismiss(animated: true)})
    }
}

extension UIViewController {
    func presentFromBottom(_ viewControllerToPresent: UIViewController, completion: (() -> Void)? = nil) {
        let transition = SlideUpTransition(onDarkBackgroundTap: {self.dismiss(animated: true)})
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = transition
        present(viewControllerToPresent, animated: true, completion: completion)
    }
}
