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
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
        else {
            return
        }

        transitionContext.containerView.addSubview(fromSnapshot)
        fromVC.view.removeFromSuperview()
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toVC.view.frame = UIScreen.main.bounds
            fromSnapshot.frame.origin.y = -fromSnapshot.frame.height / 2
        }, completion: { _ in
            fromSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    
}
