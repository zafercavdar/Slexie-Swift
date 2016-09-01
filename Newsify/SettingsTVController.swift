//
//  SettingsTVController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class SettingssTVController: UITableViewController {

    
    struct CellIdentifiers {
        static let CustomCell = "SettingsTVCell"
        static let CustomHeaderCell = "SettingsTVHeaderCell"
    }
    
    struct RouteID {
        static let LogOut = "LogOut"
    }
    
    private var model = SettingsViewModel()
    private let controller = FirebaseController()
    private var router = SettingsRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.tableBackgroundGray()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()

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
