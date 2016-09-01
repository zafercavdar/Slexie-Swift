//
//  SettingsTVController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class SettingssTVController: UITableViewController {

    private var model = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.tableBackgroundGray()
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model.sectionHeaders.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsTVCell", forIndexPath: indexPath) as! SettingsCell

        let section = indexPath.section
        let row = indexPath.row
        
        cell.menuTitle.text = model.sections[section][row]
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor.whiteColor()
        
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
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("SettingsTVHeaderCell") as! SettingsTVHeaderCell
        headerCell.backgroundColor = UIColor.cyanColor()
        
        headerCell.headerTitle.text = model.sectionHeaders[section].uppercaseString
        headerCell.headerTitle.textColor = UIColor.headerTitleGray()
        headerCell.backgroundColor = UIColor.tableBackgroundGray()
        
        return headerCell
    }
}
