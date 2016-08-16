//
//  LoginViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let fbNetworkingController = FBNetworkingController()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var randomGenerateButton: UIButton!
    
    @IBAction func generateRandomUsers(sender: UIButton) {
        
        /*fbNetworkingController.signInWith(username: "zafer", password: "112233", enableNotification: false) { (error) in
            let rgen = RandomBase()
            
            for _ in 0..<50 {
                rgen.createUser()
            }
        }*/
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.delegate = self
        passwordField.delegate = self
        
        randomGenerateButton.enabled = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if fbNetworkingController.getCurrentUser() != nil{
            performSegueWithIdentifier("LoggedIn", sender: nil)
        }
    }
    
    
    // MARK: Actions

    @IBAction func demo(sender: UIButton) {
        fbNetworkingController.signInWith(username: "private", password: "112233", enableNotification: true) { (error) in
            self.performSegueWithIdentifier("DemoPage", sender: nil)
        }
    }
    
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
    
    func loginWithUsername(username: String, _ password: String){
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: "Signing in")
        
        fbNetworkingController.signInWith(username: username, password: password, enableNotification: true) { (error) in
            loadingView.removeFromView(self.view)
            if let error = error {
                self.signInFailedNotification(error.localizedDescription)
            } else {
                self.performSegueWithIdentifier("LoggedIn", sender: nil)
            }
        }
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

