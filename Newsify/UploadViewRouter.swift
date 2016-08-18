//
//  UploadViewRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class UploadViewRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "ShowTags":
            VC.performSegueWithIdentifier("ShowTags", sender: nil)
        case "Dismiss":
            VC.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
}
