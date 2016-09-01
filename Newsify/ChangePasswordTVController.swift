//
//  ChangePasswordTVController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ChangePasswordViewModel{
    
    let placeholders = [["Current Password"],
                        ["New password", "New password, again"]]
    
}


class ChangePasswordTVController: UITableViewController {

    private var model = ChangePasswordViewModel()
    
    private struct CellIdentifiers {
        static let PasswordCell = "ChangePasswordCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(cancel(_:)))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(changePassword(_:)))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIColors()
        setUITitles()
    }
    
    // MARK: Button functions
    
    func changePassword(sender: UIBarButtonItem){
        print("change password")
    }
    
    func cancel(sender: UIBarButtonItem){
        print("cancel")
    }
    
    // MARK: UI methods
    
    private func setUIColors(){
        tableView.backgroundColor = UIColor.tableBackgroundGray()
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
    }

    
    private func setUITitles(){
        self.title = "Password"
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model.placeholders.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.placeholders[section].count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
        headerView.backgroundColor = UIColor.tableBackgroundGray()
        
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.PasswordCell, forIndexPath: indexPath) as! ChangePasswordTVCell
        
        let section = indexPath.section
        let row = indexPath.row
        
        cell.backgroundColor = UIColor.whiteColor()
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let placeholder = model.placeholders[section][row]
        cell.passwordTextField.placeholder = placeholder
        cell.passwordTextField.leftViewMode = UITextFieldViewMode.Always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
        imageView.image = UIImage(named: "password")
        imageView.contentMode = UIViewContentMode.TopLeft
        cell.passwordTextField.leftView = imageView
        
        return cell
    }



}
