//
//  SettingsRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class SettingsRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "LogOut":
            VC.performSegueWithIdentifier("LogOut", sender: nil)
        case "ChangePassword":
            VC.performSegueWithIdentifier("ChangePassword", sender: nil)
        case "Cancel":
            VC.dismissViewControllerAnimated(true, completion: nil)
        case "PrivacyPolicy":
            VC.performSegueWithIdentifier("ShowPolicy", sender: nil)
        case "ChangeLanguage":
            VC.performSegueWithIdentifier("ShowLanguageChange", sender: nil)
        case "OpenPost":
            VC.performSegueWithIdentifier("OpenPost", sender: nil)
        default:
            break
        }
    }

}