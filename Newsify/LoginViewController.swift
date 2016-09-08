//
//  LoginViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//


enum LanguageCodes: String {
    case Turkish = "tr-TR"
    case English = "en-US"
    case Russian = "ru-RU"
}

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let router = LoginRouter()
    private let loadingView = LoadingView()
    private let model = LoginViewModel()

    
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
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        setUITitlesColors()
        
    }
    
    func applyStateChange(change: LoginViewModel.State.Change) {
        switch change {
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                if loadingState.isActive {
                    self.loadingView.addToView(self.view, text: localized("SigningInInfo"))
                } else {
                    self.loadingView.removeFromView(self.view)
                }
            }
        case .loggedIn(CallbackResult.Success):
            router.routeTo(RouteID.NewsFeed, VC: self)
        case .loginAttemp(CallbackResult.Success):
            router.routeTo(RouteID.NewsFeed, VC: self)
        case .error(let error):
            signInFailedNotification(error)
        case .redirectSignup:
            router.routeTo(RouteID.CreateAccount, VC: self)
        default:
            break
        }
    }

    
    
    private func setUITitlesColors(){
        self.view.backgroundColor = UIColor.flatBlue()
        
        loginButton.setTitle(localized("LoginButton"), forState: .Normal)
        signUpRedirect.setTitle(localized("SignUpRedirect"), forState: .Normal)
        usernameLabel.text = localized("LoginScreenUsernameLabel")
        passwordLabel.text = localized("LoginScreenPasswordLabel")
        
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        usernameLabel.textColor = UIColor.whiteColor()
        passwordLabel.textColor = UIColor.whiteColor()

    }
    
    @IBAction func signUpButton(sender: UIButton) {
        model.signUpPressed()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        model.checkUserLoginStatus()
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
            model.loginWithUsername(username, password)
        } else {
            fillAllFields()
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

