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
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var turkishLanguage: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var russianButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    private var fields: [UITextField] = []
    
    private let networkingController = FirebaseController()
    private let router = SignUpRouter()
    
    private var userLanguage = "English"

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
    }
    
    private func setUIColors(){
        self.view.backgroundColor = UIColor.coreColor()
        usernameLabel.textColor = UIColor.whiteColor()
        passwordLabel.textColor = UIColor.whiteColor()
        repasswordLabel.textColor = UIColor.whiteColor()
        signUpButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        cancel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        languageLabel.textColor = UIColor.whiteColor()
        
        turkishLanguage.setTitleColor(UIColor.reddishColor(), forState: .Normal)
        englishButton.setTitleColor(UIColor.reddishColor(), forState: .Normal)
        russianButton.setTitleColor(UIColor.reddishColor(), forState: .Normal)
        profileTypeLabel.textColor = UIColor.whiteColor()
        
    }
    
    
    private func setUITitles(){
        usernameLabel.text = preferredLanguage("SignUpScreenUsernameLabel")
        passwordLabel.text = preferredLanguage("SignUpScreenPasswordLabel")
        repasswordLabel.text = preferredLanguage("SignUpScreenPasswordReTypeLabel")
        signUpButton.setTitle(preferredLanguage("SignUpScreenSignUpButton"), forState: .Normal)
        cancel.setTitle(preferredLanguage("Cancel"), forState: .Normal)
        languageLabel.text = preferredLanguage("SignUpScreenLanguageLabel")
        profileTypeLabel.text = preferredLanguage("YourProfile") + preferredLanguage("Public")
    }
    
    @IBAction func turkishPressed(sender: UIButton) {
        /*preferredLanguage = Language.Turkish
        userLanguage = "Turkish"
        
        turkishLanguage.enabled = false
        turkishLanguage.alpha = 0.5
        
        englishButton.enabled = true
        englishButton.alpha = 1
        
        russianButton.enabled = true
        englishButton.alpha = 1*/
        
        setUITitles()

    }
    
    @IBAction func englishPressed(sender: UIButton) {
        /*preferredLanguage = Language.English
        userLanguage = "English"
        
        turkishLanguage.enabled = true
        turkishLanguage.alpha = 1

        englishButton.enabled = false
        englishButton.alpha = 0.5
        
        russianButton.enabled = true
        russianButton.alpha = 1*/
        
        setUITitles()

    }
    
    @IBAction func russianPressed(sender: UIButton) {
        /*preferredLanguage = Language.Russian
        userLanguage = "Russian"
        
        turkishLanguage.enabled = true
        turkishLanguage.alpha = 1
        
        englishButton.enabled = true
        englishButton.alpha = 1
        
        russianButton.enabled = false
        russianButton.alpha = 0.5*/
        
        setUITitles()
    }
    
    
    
    @IBAction func switchStateChanged(sender: UISwitch) {
        if sender.on {
            profileTypeLabel.text = preferredLanguage("YourProfile") + preferredLanguage("Public")
        } else {
            profileTypeLabel.text = preferredLanguage("YourProfile") + preferredLanguage("Private")
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
            signUpWithUsernamePassword(email, password, username, profileType, language: userLanguage)
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
    
    private func signUpWithUsernamePassword(email: String, _ password: String, _ username: String, _ profileType: String, language: String){
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: preferredLanguage("SigningUpInfo"))
        
        
        networkingController.signUp(email, username: username, password: password, profileType: profileType, language: language) { [weak self](error) in
            
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
