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
        default:
            break
        }
    }

}