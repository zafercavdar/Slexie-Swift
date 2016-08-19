//
//  CreateAccountViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repasswordField: UITextField!
    @IBOutlet weak var accountTypeControl: UISwitch!
    @IBOutlet weak var profileTypeLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var fields: [UITextField] = []
    
    private let networkingController = FBNetworkingController()
    private let router = SignUpRouter()
    
    enum RouteID: String {
        case LoggedIn = "LoggedIn"
        case Cancel = "Cancel"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fields.append(usernameField)
        fields.append(passwordField)
        fields.append(repasswordField)
        
        for field in fields{
            field.delegate = self
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        signUpButton.setTitleColor(UIColor.coreColor(), forState: UIControlState.Normal)
        
    }

    
    
    @IBAction func switchStateChanged(sender: UISwitch) {
        if sender.on {
            profileTypeLabel.text = "Your profile: Public"
        } else {
            profileTypeLabel.text = "Your profile: Private"
        }
    }
    
    
    @IBAction func cancel(sender: UIButton) {
        self.router.routeTo(RouteID.Cancel.rawValue, VC: self)
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
        loadingView.addToView(self.view, text: "Signing up")
        
        
        networkingController.signUp(email, username: username, password: password, profileType: profileType) { [weak self](error) in
            
            guard let strongSelf = self else { return }
            
            loadingView.removeFromView(strongSelf.view)

            if let error = error {
                strongSelf.signUpFailedNotification(error.localizedDescription)
            } else {
                strongSelf.router.routeTo(RouteID.LoggedIn.rawValue, VC: strongSelf)
            }
            
        }
    }

    // MARK: UITextFieldDelegate
    
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        resignAllFirstResponder()
        return true
    }
    

}
