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
            //ENSession.shared.viewNoteInEvernote(noteRef)
            EvernoteIntegration.openInEvernote(noteRef)
        }
    }
    
    func showBanner(text: String) {
        let showDuration = 2.5
        banner.titleLabel?.adjustsFontSizeToFitWidth = true
        banner.setTitle(text, for: .normal)
        banner.backgroundColor = .darkGray
        banner.alpha = 1
        
        // Animate banner expansion
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: {
            self.bannerHeight.constant = 64 // TODO: Don't hardcode
            self.view.layoutIfNeeded()
            self.banner.backgroundColor = .black
        }, completion: { finished in
            // Tappable phase
            UIView.animate(withDuration: 0.01, delay: showDuration, options: .allowUserInteraction, animations: {
                self.banner.backgroundColor = .darkGray
            }, completion: { finished in
                // Animate disappearing banner
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                    self.bannerHeight.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.banner.alpha = 0
                })
            })
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
