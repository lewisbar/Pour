//
//  SettingsTVC.swift
//  Pour
//
//  Created by Lennart Wisbar on 21.10.19.
//  Copyright © 2019 Lennart Wisbar. All rights reserved.
//

import UIKit
import EvernoteSDK

class SettingsTVC: UITableViewController {
    
    var username: String?
    var notebooks: [ENNotebook]?
    var defaultNotebook: ENNotebook?
    var defaultPourNotebook: String?
    
    init() {
        let style: UITableView.Style
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        } else {
            // Fallback on earlier versions
            style = .grouped
        }
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EvernoteIntegration.authenticate(with: self) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.username = ENSession.shared.userDisplayName
            ENSession.shared.listWritableNotebooks { (notebooks, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.notebooks = notebooks
                
                self.defaultNotebook = notebooks?.first(where: { $0.isDefaultNotebook })
                
                self.tableView.reloadData()
            }
        }
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "Settings Cell")
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Settings Cell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Account"
            cell.detailTextLabel?.text = self.username
        case 1:
            cell.textLabel?.text = "Notebook"
            cell.detailTextLabel?.text = self.defaultNotebook?.name ?? ""
        case 2:
            cell.textLabel?.text = "Tags"
            cell.detailTextLabel?.text = ""
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Evernote Account Settings"
    }

}
