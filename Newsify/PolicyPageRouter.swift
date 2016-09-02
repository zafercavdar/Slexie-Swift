//
//  PolicyPageRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 02/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class PolicyPageRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "Back":
            VC.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
}