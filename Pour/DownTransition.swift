//
//  DownTransition.swift
//  Pour
//
//  Created by Lennart Wisbar on 25.11.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class DownTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
        else {
            return
        }
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(fromSnapshot)
        let toVCHeight = toVC.view.frame.height
        toVC.view.frame = CGRect(x: 0, y: -toVC.view.frame.height / 2, width: toVC.view.frame.width, height: toVCHeight)
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toVC.view.frame.origin.y = 0
            fromSnapshot.frame.origin.y = toVCHeight / 2
        }, completion: { _ in
            fromVC.view.frame = fromSnapshot.frame
            fromSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
