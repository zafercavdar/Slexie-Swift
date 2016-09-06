//
//  ProfileRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfileRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "Settings":
            //let settingsTVController = SettingsTVController()
            //VC.navigationController!.presentViewController(settingsTVController, animated: true, completion: nil)
            VC.performSegueWithIdentifier("Settings", sender: nil)
        default:
            break
        }
    }
}

