//
//  UpTransition.swift
//  Pour
//
//  Created by Lennart Wisbar on 25.11.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class UpTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
//            let nav = toVC as? UINavigationController,
//            let settingsVC = nav.viewControllers.first,
//            let fromSnapshot = settingsVC.view.snapshotView(afterScreenUpdates: false)
        else {
            return
        }
        // transitionContext.containerView.addSubview(toVC.view)
        // fromVC.view.frame.origin.y = -fromVC.view.frame.height / 2

        // fromSnapshot.frame = fromVC.view.frame
        // transitionContext.containerView.addSubview(toVC.view)

        // mainVC.statusBarHidden = true
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toVC.view.frame = UIScreen.main.bounds
            fromVC.view.frame.origin.y = -fromVC.view.frame.height / 2
            // mainVC.statusBarHidden = false
        }, completion: { _ in
            // fromVC.view.frame.origin.y = -fromVC.view.frame.height / 2
            // fromVC.view.frame = fromSnapshot.frame
            // fromSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    
}
