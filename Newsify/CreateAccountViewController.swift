//
//  CreateAccountViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    
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
    
    private let networkingController = FirebaseController()
    private let router = SignUpRouter()
    
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
        
        self.view.backgroundColor = UIColor.coreColor()
        usernameLabel.text = preferredLanguage.SignUpScreenUsernameLabel
        usernameLabel.textColor = UIColor.whiteColor()
        passwordLabel.text = preferredLanguage.SignUpScreenPasswordLabel
        passwordLabel.textColor = UIColor.whiteColor()
        repasswordLabel.text = preferredLanguage.SignUpScreenPasswordReTypeLabel
        repasswordLabel.textColor = UIColor.whiteColor()
        signUpButton.setTitle(preferredLanguage.SignUpScreenSignUpButton, forState: .Normal)
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancel.setTitle(preferredLanguage.Cancel, forState: .Normal)
        cancel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        profileTypeLabel.textColor = UIColor.whiteColor()
        profileTypeLabel.text = preferredLanguage.YourProfile + preferredLanguage.Public
        
    }
    
    @IBAction func switchStateChanged(sender: UISwitch) {
        if sender.on {
            profileTypeLabel.text = preferredLanguage.YourProfile + preferredLanguage.Public
        } else {
            profileTypeLabel.text = preferredLanguage.YourProfile + preferredLanguage.Private
        }
    }
    
    
    @IBAction func cancel(sender: UIButton) {
        self.router.routeTo(RouteID.Cancel, VC: self)
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
            signUpWithUsernamePassword(email, password, username, profileType)
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
    
    private func signUpWithUsernamePassword(email: String, _ password: String, _ username: String, _ profileType: String){
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: preferredLanguage.SigningUpInfo)
        
        
        networkingController.signUp(email, username: username, password: password, profileType: profileType) { [weak self](error) in
            
            guard let strongSelf = self else { return }
            
            loadingView.removeFromView(strongSelf.view)

            if let error = error {
                strongSelf.signUpFailedNotification(error.localizedDescription)
            } else {
                strongSelf.router.routeTo(RouteID.LoggedIn, VC: strongSelf)
            }
            
        }
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        resignAllFirstResponder()
        return true
    }
    

}
