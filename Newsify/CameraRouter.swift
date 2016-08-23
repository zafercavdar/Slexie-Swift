//
//  CameraRouter.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

import UIKit

class CameraRouter: Router {
    
    func routeTo(routeID: String, VC: UIViewController){
        
        switch routeID {
        case "Upload":
            VC.tabBarController?.selectedIndex = 4
        case "toFeed":
            VC.tabBarController?.selectedIndex = 0
        case "Dismiss":
            VC.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
}

