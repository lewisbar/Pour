//
//  NotebookCell.swift
//  Pour
//
//  Created by Lennart Wisbar on 14.11.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit

class NotebookCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
