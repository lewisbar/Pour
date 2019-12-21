//
//  Helpers.swift
//  Pour
//
//  Created by Lennart Wisbar on 21.12.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import Foundation

struct Helpers {
    
    static func titleFromCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd [hh:mm]"
        let title = formatter.string(from: date)
        return title
    }
}
