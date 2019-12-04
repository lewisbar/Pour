//
//  UnlinkButton.swift
//  Pour
//
//  Created by Lennart Wisbar on 18.11.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class UnlinkButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = #colorLiteral(red: 0.7200477123, green: 0, blue: 0.048787646, alpha: 1)
        self.setTitle("Unlink from Evernote", for: .normal)
        self.setTitleColor(.white, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
