//
//  ViewController+AppearingViews.swift
//  Pour
//
//  Created by Lennart Wisbar on 09.10.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit
import EvernoteSDK

extension ViewController {
    
    @IBAction func bannerTouched(_ sender: UIButton) {
        if let noteRef = noteRef {
            ENSession.shared.viewNoteInEvernote(noteRef)
        }
    }
    
    func showBanner(text: String) {
        let duration = 3.0
        banner.titleLabel?.adjustsFontSizeToFitWidth = true
        banner.setTitle(text, for: .normal)
        banner.backgroundColor = .darkGray
        banner.alpha = 1
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.015) {
                self.bannerHeight.constant = 64 // TODO: Don't hardcode
                self.view.layoutIfNeeded()
                self.banner.backgroundColor = .black
            }
            UIView.addKeyframe(withRelativeStartTime: 0.98, relativeDuration: 0.01) {
                self.banner.backgroundColor = .darkGray
            }
            UIView.addKeyframe(withRelativeStartTime: 0.99, relativeDuration: 0.01) {
                self.bannerHeight.constant = 0
                self.view.layoutIfNeeded()
            }
        }, completion: { (finished) in
            self.banner.alpha = 0
        })
    }
    
    func showActivity() {
        let spreadBackground = {
            self.activityViewWidth.constant = 48 // TODO: Don't hardcode
            self.activityViewHeight.constant = 48 // TODO: Don't hardcode
            self.view.layoutIfNeeded()
        }
        
        let showActivityIndicator = { (finished: Bool) in
            self.activityIndicator.alpha = 1
            self.activityIndicator.startAnimating()
        }
        
        UIView.animate(withDuration: 0.3, animations: spreadBackground, completion: showActivityIndicator)
    }
    
    func hideActivity() {
        self.activityIndicator.alpha = 0
        self.activityIndicator.stopAnimating()
        self.activityViewWidth.constant = 0
        self.activityViewHeight.constant = 0
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
