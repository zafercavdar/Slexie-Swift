//
//  NotificationsRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 07/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class NotificationsRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "DetailedSinglePost":
            VC.performSegueWithIdentifier("DetailedSinglePost", sender: nil)
        default:
            break
        }
    }
}