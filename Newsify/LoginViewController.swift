//
//  LoginViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let fbNetworkingController = FirebaseController()
    private let router = LoginRouter()
    
    struct RouteID {
        static let NewsFeed = "Newsfeed"
        static let CreateAccount = "CreateAccount"
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpRedirect: UIButton!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        setUITitlesColors()
        
    }
    
    private func setUITitlesColors(){
        self.view.backgroundColor = UIColor.coreColor()
        
        loginButton.setTitle(preferredLanguage.LoginButton, forState: .Normal)
        signUpRedirect.setTitle(preferredLanguage.SignUpRedirect, forState: .Normal)
        usernameLabel.text = preferredLanguage.LoginScreenUsernameLabel
        passwordLabel.text = preferredLanguage.LoginScreenPasswordLabel
        
        
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        usernameLabel.textColor = UIColor.whiteColor()
        passwordLabel.textColor = UIColor.whiteColor()

    }
    
    @IBAction func signUpButton(sender: UIButton) {
        router.routeTo(RouteID.CreateAccount, VC: self)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if fbNetworkingController.getCurrentUser() != nil{
            router.routeTo(RouteID.NewsFeed, VC: self)
        }
    }
    
    
    // MARK: Actions

    @IBAction func loginButton(sender: UIButton) {
        
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        let username = usernameField.text!
        let password = passwordField.text!
        let usernameExists = !username.isEmpty
        let passwordExists = !password.isEmpty
        
        
        if usernameExists && passwordExists {
            loginWithUsername(username, password)
        } else {
            fillAllFields()
        }
        
    }
    
    // MARK: Helper methods
    
    private func loginWithUsername(username: String, _ password: String){
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: preferredLanguage.SigningInInfo)
        
        fbNetworkingController.signInWith(username: username, password: password, enableNotification: true) { [weak self](error) in
            
            guard let strongSelf = self else { return }

            loadingView.removeFromView(strongSelf.view)
            if let error = error {
                strongSelf.signInFailedNotification(error.localizedDescription)
            } else {
                strongSelf.fbNetworkingController.fetchUserLanguage(completion: {
                    strongSelf.router.routeTo(RouteID.NewsFeed, VC: strongSelf)
                })
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}

