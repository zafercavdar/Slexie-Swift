//
//  SignUpRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class SignUpRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "LoggedIn":
            VC.performSegueWithIdentifier("LoggedInFromSignUp", sender: nil)
        case "Cancel":
            VC.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
}

