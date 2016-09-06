//
//  CreateAccountViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repasswordLabel: UILabel!
    @IBOutlet weak var repasswordField: UITextField!
    @IBOutlet weak var accountTypeControl: UISwitch!
    @IBOutlet weak var profileTypeLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    private var fields: [UITextField] = []
    
    private let router = SignUpRouter()
    private let model = CreateAccountViewModel()
    
    private let loadingView = LoadingView()
    
    private var userLanguage = NSBundle.mainBundle().preferredLocalizations.first! as String

    struct RouteID {
        static let LoggedIn = "LoggedIn"
        static let Cancel = "Cancel"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fields.append(usernameField)
        fields.append(passwordField)
        fields.append(repasswordField)
        
        for field in fields{
            field.delegate = self
        }
        
        setUIColors()
        setUITitles()
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
    }
    
    func applyStateChange(change: CreateAccountViewModel.State.Change) {
        switch change {
        case .loadingView:
            loadingView.addToView(self.view, text: localized("SigningUpInfo"))
        case .removeView:
            loadingView.removeFromView(self.view)
        case .signUpAttemp(CallbackResult.Success):
            self.router.routeTo(RouteID.LoggedIn, VC: self)
        case .cancel:
            self.router.routeTo(RouteID.Cancel, VC: self)
        case .error(let error):
            signUpFailedNotification(error)
        default:
            break
        }
    }

    
    private func setUIColors(){
        self.view.backgroundColor = UIColor.flatBlue()
        usernameLabel.textColor = UIColor.whiteColor()
        passwordLabel.textColor = UIColor.whiteColor()
        repasswordLabel.textColor = UIColor.whiteColor()
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        profileTypeLabel.textColor = UIColor.whiteColor()
        
    }
    
    
    private func setUITitles(){
        usernameLabel.text = localized("SignUpScreenUsernameLabel")
        passwordLabel.text = localized("SignUpScreenPasswordLabel")
        repasswordLabel.text = localized("SignUpScreenPasswordReTypeLabel")
        signUpButton.setTitle(localized("SignUpScreenSignUpButton"), forState: .Normal)
        cancel.setTitle(localized("Cancel"), forState: .Normal)
        profileTypeLabel.text = localized("YourProfile") + localized("Public")
    }
    
    
    
    
    @IBAction func switchStateChanged(sender: UISwitch) {
        if sender.on {
            profileTypeLabel.text = localized("YourProfile") + localized("Public")
        } else {
            profileTypeLabel.text = localized("YourProfile") + localized("Private")
        }
    }
    
    
    @IBAction func cancel(sender: UIButton) {
        model.cancelPressed()
    }
    
    
    @IBAction func createAccount(sender: UIButton) {
        
        resignAllFirstResponder()
        
        let username = usernameField.text!
        let password = passwordField.text!
        let repassword = repasswordField.text!
        let email = username + "@slexie.com"
        let usernameExists = !username.isEmpty
        let passwordExists = !password.isEmpty
        let profileType = accountTypeControl.on ? "Public" : "Private"
        
        if usernameExists && passwordExists && password == repassword{
            model.signUpWithUsernamePassword(email, password, username, profileType, language: userLanguage)
        }else if !usernameExists || !passwordExists{
            fillAllFields()
        }
        else if password != repassword{
            passwordsDoNotMatch()
        }
    }
    
    // MARK: Helper Methods
    
    private func resignAllFirstResponder(){
        for field in fields{
            field.resignFirstResponder()
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        resignAllFirstResponder()
        return true
    }
    

}
