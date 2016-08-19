//
//  LoginViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let fbNetworkingController = FBNetworkingController()
    private let router = LoginRouter()
    
    enum RouteID: String {
        case NewsFeed = "Newsfeed"
        case CreateAccount = "CreateAccount"
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var randomGenerateButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        
    }
    
    @IBAction func signUpButton(sender: UIButton) {
        router.routeTo(RouteID.CreateAccount.rawValue, VC: self)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.setTitleColor(UIColor.coreColor(), forState: UIControlState.Normal)
        randomGenerateButton.enabled = false

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if fbNetworkingController.getCurrentUser() != nil{
            router.routeTo(RouteID.NewsFeed.rawValue, VC: self)
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
    
    @IBAction func generateRandomUsers(sender: UIButton) {
        
        fbNetworkingController.signInWith(username: "zafer", password: "112233", enableNotification: false) { (error) in
         let rgen = RandomBase()
         
            for _ in 0..<50 {
                rgen.createUser()
            }
        }
    }

    
    // MARK: Helper methods
    
    private func loginWithUsername(username: String, _ password: String){
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: "Signing in")
        
        fbNetworkingController.signInWith(username: username, password: password, enableNotification: true) { [weak self](error) in
            
            guard let strongSelf = self else { return }

            loadingView.removeFromView(strongSelf.view)
            if let error = error {
                strongSelf.signInFailedNotification(error.localizedDescription)
            } else {
                strongSelf.router.routeTo(RouteID.NewsFeed.rawValue, VC: strongSelf)
            }
        }
        
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

