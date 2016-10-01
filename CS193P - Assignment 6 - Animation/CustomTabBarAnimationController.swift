//
//  FlipPresentAnimationController.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 29/09/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

class CustomTabBarAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

//    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {   guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        else { return }
        let containerView = transitionContext.containerView
        let finalFrameForVC = transitionContext.finalFrame(for: toVC)
        let bounds = UIScreen.main.bounds
        toVC.view.frame = finalFrameForVC.offsetBy(dx: 0, dy: bounds.size.height)
        containerView.addSubview(toVC.view)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.0,
            options: [.curveLinear],
            animations: {
                fromVC.view.alpha = 0.8
                toVC.view.frame = finalFrameForVC
            },
            completion: { finished in
                transitionContext.completeTransition(true)
                fromVC.view.alpha = 1.0
            })
    }
    
    
}
