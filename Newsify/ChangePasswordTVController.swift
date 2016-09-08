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
    
    struct State {
        
        var loadingState = LoadingState()
        
        enum Change: Equatable{
            case loading(LoadingState)
        }
        
        mutating func addActivity() -> Change {
            
            loadingState.addActivity()
            return Change.loading(loadingState)
        }
        
        mutating func removeActivity() -> Change {
            
            loadingState.removeActivity()
            return .loading(loadingState)
        }
    }
    
    private var controller = FirebaseController()
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    func isPasswordCorrect(oldPassword: String, completion callback: (Bool) -> Void){
        self.emit(self.state.addActivity())
        controller.isPasswordCorrect(oldPassword) { (isCorrect) in
            self.emit(self.state.removeActivity())
            callback(isCorrect)
        }
    }
    
    func changePassword(oldPassword: String, newPassword: String, completion callback: (NSError?) -> Void){
        self.emit(self.state.addActivity())
        controller.changePassword(oldPassword, newPassword: newPassword) { (error) in
            self.emit(self.state.removeActivity())
            callback(error)
        }
    }
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
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
    private let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        cancelButton = UIBarButtonItem(title: localized("Cancel"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancel(_:)))
        
        doneButton = UIBarButtonItem(title: localized("Done"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(changePassword(_:)))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIColors()
        setUITitles()
    }
    
    func applyStateChange(change: ChangePasswordViewModel.State.Change) {
        switch change {
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                if loadingState.isActive {
                    self.loadingView.addToView(self.view, text: localized("RefreshingInfo"))
                } else {
                    self.loadingView.removeFromView(self.view)
                }
            }
        }
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
        
        //let fields = [oldPasswordField, newPasswordField, rePasswordField]
        
        model.isPasswordCorrect(oldPassword!) { [weak self] (isCorrect) in
            guard let strongSelf = self else { return }

            let passViewBlack = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
            passViewBlack.contentMode = UIViewContentMode.TopLeft
            let passViewRed = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
            passViewRed.contentMode = UIViewContentMode.TopLeft
            passViewBlack.image = UIImage(named: "password")
            passViewRed.image = UIImage(named: "password-error")

            var willChangeField: UITextField?
            
            if (!isCorrect){
                
                strongSelf.showErrorView(with: localized("ErrorCurrentPasswordIsWrong"))
                
                willChangeField = oldPasswordField
            } else {
                oldPasswordField.leftView = passViewBlack
                
                if newPassword != rePassword {
                    
                    strongSelf.showErrorView(with: localized("ErrorPasswordsDoNotMatch"))
                    
                    willChangeField = rePasswordField
                    
                } else {
                    
                    if newPassword?.characters.count < 6 {
                        strongSelf.showErrorView(with: localized("ErrorPasswordLength"))
                        willChangeField = newPasswordField
                    } else {
                        // Everything is OK
                        
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
            
            /*for field in fields {
                if field != willChangeField {
                    field.leftView = passViewBlack
                } else {
                    field.leftView = passViewRed
                }
            }*/
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

func ==(lhs: ChangePasswordViewModel.State.Change, rhs: ChangePasswordViewModel.State.Change) -> Bool {
    
    switch (lhs, rhs) {
    case (.loading(let loadingState1), .loading(let loadingState2)):
        return loadingState1.activityCount == loadingState2.activityCount
    }
}

