//
//  TagsTableRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class TagsTableRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "Cancel":
            VC.dismissViewControllerAnimated(true, completion: nil)
        case "Upload":
            VC.performSegueWithIdentifier("ReturnToProfile", sender: nil)
        default:
            break
        }
    }
    
}
