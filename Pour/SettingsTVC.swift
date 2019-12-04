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
        // let f = tableView.frame
        // let oldTVHeight = f.height
        // let newTVHeight = oldTVHeight / 2 - mainVCSafeAreaTopInset
        // tableView.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.width, height: newTVHeight)
        tableView.backgroundColor = .black
        tableView.separatorColor = .clear
        let doneButton = UIBarButtonItem(title: "\u{2715}", style: .plain, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = doneButton
        tableView.alwaysBounceVertical = false
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "Settings Cell")
        
        updateFooterView(link: !ENSession.shared.isAuthenticated)
        
        let screen = UIScreen.main.bounds
        let lowerTableViewEdge = (view.frame.height / 2) - (mainVCSafeAreaTopInset) - 14  // TODO: Why the 14?
        let dismissButtonHeight = screen.height - lowerTableViewEdge
        let dismissButton = UIButton(frame: CGRect(x: 0, y: lowerTableViewEdge, width: view.frame.width, height: dismissButtonHeight))  // TODO: Why these numbers?
        dismissButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(dismissButton)
        
        if ENSession.shared.isAuthenticated {
            loadAccountData()
        }
    }
    
    func updateFooterView(link: Bool) {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 50))
        var button: UIButton
        
        if ENSession.shared.isAuthenticated {
            button = UnlinkButton(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 50))
            button.addTarget(self, action: #selector(unlinkEvernote), for: .touchUpInside)
        } else {
            button = LinkButton(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32, height: 50))
            button.addTarget(self, action: #selector(linkEvernote), for: .touchUpInside)
        }
        container.addSubview(button)
        tableView.tableFooterView = container
    }
    
    @objc func linkEvernote() {
        EvernoteIntegration.authenticate(with: self, completion: { _ in
            self.loadAccountData()
            self.updateFooterView(link: !ENSession.shared.isAuthenticated)
        })
    }
    
    @objc func unlinkEvernote() {
        ENSession.shared.unauthenticate()
        tableView.reloadData()
        self.updateFooterView(link: !ENSession.shared.isAuthenticated)
    }
    
    fileprivate func loadAccountData() {
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
        if ENSession.shared.isAuthenticated {
            return 3
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Settings Cell", for: indexPath)
        
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
        let container = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: container.frame.width, height: 28))
        titleLabel.text = "Settings"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        return container
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
