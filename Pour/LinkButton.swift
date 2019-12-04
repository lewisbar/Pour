//
//  LinkButton.swift
//  Pour
//
//  Created by Lennart Wisbar on 18.11.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class LinkButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = #colorLiteral(red: 0, green: 0.6676516533, blue: 0.07127974182, alpha: 1)
        self.setTitle("Link to Evernote", for: .normal)
        self.setTitleColor(.white, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
