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
        print(fromVC.view.frame)
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(fromSnapshot)
        let toVCHeight = toVC.view.frame.height / 2
        toVC.view.frame = CGRect(x: 0, y: -toVC.view.frame.height / 2, width: toVC.view.frame.width, height: toVCHeight)
        
        // fromSnapshot?.frame = fromVC.view.frame
        
        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            print(fromVC.view.frame)
            toVC.view.frame.origin.y = 0
            fromSnapshot.frame.origin.y = toVCHeight
            print(fromVC.view.frame)
        }, completion: { _ in
            fromVC.view.frame = fromSnapshot.frame
            fromSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    
}
