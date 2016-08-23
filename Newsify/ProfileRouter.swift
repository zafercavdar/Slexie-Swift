//
//  ProfileRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class ProfileRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "LogOut":
            VC.performSegueWithIdentifier("LogOut", sender: nil)
        default:
            break
        }
    }
}

