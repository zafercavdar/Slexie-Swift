//
//  SettingsTVController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

enum Privacy{
    case Public
    case Private
}

class SettingsTVController: UITableViewController {

    
    struct CellIdentifiers {
        static let CustomCell = "SettingsTVCell"
        static let CustomHeaderCell = "SettingsTVHeaderCell"
    }
    
    struct RouteID {
        static let LogOut = "LogOut"
        static let ChangePassword = "ChangePassword"
        static let Cancel = "Cancel"
    }
    
    private var model = SettingsViewModel()
    private let controller = FirebaseController()
    private var router = SettingsRouter()
    
    private var backButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton = UIBarButtonItem(title: "< Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backButtonPressed(_:)))
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUIColors()
        setUITitles()
    }
    
    // MARK: Selector methods
    
    func backButtonPressed(sender: UIBarButtonItem){
        self.router.routeTo(RouteID.Cancel, VC: self)
    }
    
    // MARK: UI Settings
    
    private func setUIColors(){
        tableView.backgroundColor = UIColor.tableBackgroundGray()
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
    }
    
    private func setUITitles(){
        self.navigationController?.title = "Settings"
    }
    
    func privacyChanged(sender: UISwitch){
        
        let title = "Change Privacy?"
        var message = ""
        var privacy: Privacy
        
        if sender.on {
            message = "Your profile will be PRIVATE and none of your photos will be available for other users."
            privacy = Privacy.Private
        } else {
            message = "Your profile will be PUBLIC and all of your photos will be available for other users."
            privacy = Privacy.Public
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let noAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
            sender.setOn(!sender.on, animated: true)
        })
        
        let yesAction = UIAlertAction(title: "Okay", style: .Default, handler: { [weak self] (action: UIAlertAction!) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.model.setPrivacy(privacy)
        })
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model.sectionHeaders.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.CustomCell, forIndexPath: indexPath) as! SettingsCell

        let section = indexPath.section
        let row = indexPath.row
        
        cell.menuTitle.text = model.sections[section][row]
        cell.backgroundColor = UIColor.whiteColor()
        
        if !(section == 0 && row == 2) {
            cell.accessoryType = .DisclosureIndicator
        } else {
            let privacySwitch = UISwitch()
            privacySwitch.onTintColor = UIColor.reddishColor()
            
            model.isPrivateAccount({ (isPrivate) in
                privacySwitch.setOn(isPrivate, animated: false)
            })
            
            privacySwitch.addTarget(self, action: #selector(privacyChanged(_:)), forControlEvents: .ValueChanged)
            cell.accessoryView = privacySwitch
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
        footerView.backgroundColor = UIColor.tableBackgroundGray()
        
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.CustomHeaderCell) as! SettingsTVHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        
        headerCell.headerTitle.text = model.sectionHeaders[section].uppercaseString
        headerCell.headerTitle.textColor = UIColor.headerTitleGray()
        headerCell.backgroundColor = UIColor.tableBackgroundGray()
        
        return headerCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        // Change password cell
        if (section == 0 && row == 1){
            self.router.routeTo(RouteID.ChangePassword, VC: self)
        }
        
        // Log out cell
        if (section == 3 && row == 0){
            logOut()
        }
    }
    
    private func logOut(){
        controller.signOut { [weak self] (Void) in
            guard let strongSelf = self else { return }
            strongSelf.router.routeTo(RouteID.LogOut, VC: strongSelf)
        }
    }
    
}
