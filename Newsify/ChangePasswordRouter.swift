//
//  ChangePasswordRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 02/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ChangePasswordRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "Done":
            VC.dismissViewControllerAnimated(true, completion: nil)
        case "Cancel":
            VC.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
}