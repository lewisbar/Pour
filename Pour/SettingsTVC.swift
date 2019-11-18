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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
