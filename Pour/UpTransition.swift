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
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            return
        }

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromVC.view.frame.origin.y = -fromVC.view.frame.height
            toVC.view.frame = UIScreen.main.bounds
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    
}
