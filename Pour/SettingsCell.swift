//
//  SettingsCell.swift
//  Pour
//
//  Created by Lennart Wisbar on 18.11.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = .darkGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
