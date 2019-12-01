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
    var mainVCSafeAreaTopInset: CGFloat!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
        let f = tableView.frame
        let newHeight = f.height / 2 + mainVCSafeAreaTopInset
        tableView.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.width, height: newHeight)
        tableView.backgroundColor = .black
        tableView.separatorColor = .clear
        let doneButton = UIBarButtonItem(title: "\u{2715}", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = doneButton
        tableView.alwaysBounceVertical = false
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "Settings Cell")
        
        let screen = UIScreen.main.bounds
        let dismissButton = UIButton(frame: CGRect(x: 0, y: screen.height / 2.5, width: screen.width, height: screen.height / 1.5))  // TODO: Why these numbers?
        dismissButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(dismissButton)
                
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
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .clear
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
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .lightGray
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Evernote Account"
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48))
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: container.frame.width, height: 28))
        titleLabel.text = "Settings"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        return container
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
