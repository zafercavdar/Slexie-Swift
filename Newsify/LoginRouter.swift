//
//  LoginRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class LoginRouter: Router {

    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "Newsfeed":
            VC.performSegueWithIdentifier("LoggedIn", sender: nil)
        case "CreateAccount":
            VC.performSegueWithIdentifier("CreateAccountSegue", sender: nil)
        default:
            break
        }
    }
    
    
}
