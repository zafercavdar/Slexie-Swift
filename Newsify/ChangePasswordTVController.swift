//
//  ChangePasswordTVController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ChangePasswordViewModel{
    
    let placeholders = [[localized("CurrentPassword")],
                        [localized("NewPassword"), localized("NewPasswordAgain")]]
    
    private var controller = FirebaseController()
    
    func isPasswordCorrect(oldPassword: String, completion callback: (Bool) -> Void){
        controller.isPasswordCorrect(oldPassword) { (isCorrect) in
            callback(isCorrect)
        }
    }
    
    func changePassword(oldPassword: String, newPassword: String, completion callback: (NSError?) -> Void){
        controller.changePassword(oldPassword, newPassword: newPassword) { (error) in
            callback(error)
        }
    }
}


class ChangePasswordTVController: UITableViewController{

    private var model = ChangePasswordViewModel()
    private var router = ChangePasswordRouter()
    
    private struct CellIdentifiers {
        static let PasswordCell = "ChangePasswordCell"
    }
    
    private struct RouteID{
        static let Done = "Done"
        static let Cancel = "Cancel"
    }
    
    private var cancelButton = UIBarButtonItem()
    private var doneButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        cancelButton = UIBarButtonItem(title: localized("Cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancel(_:)))
        
        doneButton = UIBarButtonItem(title: localized("Done"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(changePassword(_:)))
        
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
        let oldPasswordIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let oldPasswordField = (tableView.cellForRowAtIndexPath(oldPasswordIndexPath) as! ChangePasswordTVCell).passwordTextField
        let oldPassword = oldPasswordField.text
        
        let newPasswordIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        let newPasswordField = (tableView.cellForRowAtIndexPath(newPasswordIndexPath) as! ChangePasswordTVCell).passwordTextField
        let newPassword = newPasswordField.text
        
        let rePasswordIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        let rePasswordField = (tableView.cellForRowAtIndexPath(rePasswordIndexPath) as! ChangePasswordTVCell).passwordTextField
        let rePassword = rePasswordField.text
        
        model.isPasswordCorrect(oldPassword!) { [weak self] (isCorrect) in
            guard let strongSelf = self else { return }

            let passViewBlack = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
            passViewBlack.contentMode = UIViewContentMode.TopLeft
            let passViewRed = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
            passViewRed.contentMode = UIViewContentMode.TopLeft
            passViewBlack.image = UIImage(named: "password")
            passViewRed.image = UIImage(named: "password-error")

            if (!isCorrect){
                
                strongSelf.showErrorView(with: localized("ErrorCurrentPasswordIsWrong"))
                
                //oldPasswordField.leftView = passViewRed
            } else {
                oldPasswordField.leftView = passViewBlack
                
                if newPassword != rePassword {
                    
                    strongSelf.showErrorView(with: localized("ErrorPasswordsDoNotMatch"))
                    
                    //newPasswordField.leftView = passViewRed
                    //rePasswordField.leftView = passViewRed
                    
                } else {
                    //newPasswordField.leftView = passViewBlack
                    //rePasswordField.leftView = passViewBlack
                    
                    if newPassword?.characters.count < 6 {
                        strongSelf.showErrorView(with: localized("ErrorPasswordLength"))
                        //newPasswordField.leftView = passViewRed
                        //rePasswordField.leftView = passViewBlack
                    } else {
                        // Everything is OK
                        //rePasswordField.leftView = passViewBlack
                        //newPasswordField.leftView = passViewBlack
                        
                        strongSelf.doneButton.enabled = false

                        strongSelf.model.changePassword(oldPassword!,newPassword: newPassword!, completion: { (error) in
                            strongSelf.doneButton.enabled = true
                            
                            if error == nil {
                                strongSelf.showDoneView(with: localized("SuccessPasswordChanged"))
                                NSTimer.scheduledTimerWithTimeInterval(3, target: strongSelf, selector: #selector(strongSelf.callRouter), userInfo: nil, repeats: false)
                                
                            } else {
                                strongSelf.showErrorView(with: localized("ErrorUnexpected"))
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func showErrorView(with text: String){
        var errorView = CustomErrorView()
        
        UIView.animateWithDuration(0.6, animations: {
            self.tableView.tableHeaderView = errorView.createView(text)
        })
        
        NSTimer.scheduledTimerWithTimeInterval(3.5, target: self, selector: #selector(self.removeErrorView), userInfo: nil, repeats: false)
    }
    
    private func showDoneView(with text: String){
        var doneView = CustomDoneView()
        
        UIView.animateWithDuration(0.6, animations: {
            self.tableView.tableHeaderView = doneView.createView(text)
        })
    }
    
    func removeErrorView(){
        UIView.animateWithDuration(0.6, animations: {
            self.tableView.tableHeaderView = nil
        })
    }
    
    func callRouter(){
        self.router.routeTo(RouteID.Done, VC: self)
    }
    
    func cancel(sender: UIBarButtonItem){
        self.router.routeTo(RouteID.Cancel, VC: self)
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
        self.title = localized("Password")
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
        return 30.0
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
