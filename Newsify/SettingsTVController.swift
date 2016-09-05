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
        static let PrivacyPolicy = "PrivacyPolicy"
        static let ChangeLanguage = "ChangeLanguage"
        static let OpenPost = "OpenPost"
    }
    
    private var model = SettingsViewModel()
    private let controller = FirebaseController()
    private var router = SettingsRouter()
    
    private var backButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonImage = UIImage(named: "backButton")
        backButton = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backButtonPressed(_:)))
        
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
        self.title = localized("Settings")
    }
    
    func privacyChanged(sender: UISwitch){
        
        let title = localized("ChangePrivacy")
        var message = ""
        var privacy: Privacy
        
        if sender.on {
            message = localized("PrivateWarning")
            privacy = Privacy.Private
        } else {
            message = localized("PublicWarning")
            privacy = Privacy.Public
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.view.tintColor = UIColor.reddishColor()
        
        let noAction = UIAlertAction(title: localized("Cancel"), style: .Default, handler: { (action: UIAlertAction!) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
            sender.setOn(!sender.on, animated: true)
        })
        
        let yesAction = UIAlertAction(title: localized("Okay"), style: .Default, handler: { [weak self] (action: UIAlertAction!) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.model.setPrivacy(privacy)
        })
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
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
        
        headerCell.headerTitle.text = model.sectionHeaders[section].uppercaseString
        headerCell.headerTitle.textColor = UIColor.headerTitleGray()
        headerCell.backgroundColor = UIColor.tableBackgroundGray()
        
        return headerCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        
        // Temporaryly postview controller
        
        if (section == 0 && row == 0){
            self.router.routeTo(RouteID.OpenPost, VC: self)
        }
        
        // Change password
        if (section == 0 && row == 1){
            self.router.routeTo(RouteID.ChangePassword, VC: self)
        }
        
        // Change language
        if (section == 1 && row == 0){
            self.router.routeTo(RouteID.ChangeLanguage, VC: self)
        }
        
        // Privacy Policy
        if (section == 2 && row == 0){
            self.router.routeTo(RouteID.PrivacyPolicy, VC: self)
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
