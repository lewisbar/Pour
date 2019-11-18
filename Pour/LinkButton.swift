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
        self.backgroundColor = .green
        self.titleLabel?.textColor = .white
        self.titleLabel?.text = "Link to Evernote"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
