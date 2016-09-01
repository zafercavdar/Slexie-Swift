//
//  MainTabbarController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController, UITabBarControllerDelegate {

    var lastViewController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {

    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        if tabBarController.viewControllers![0] == viewController {
            if lastViewController == viewController {
                let VC = (viewController as! UINavigationController).viewControllers.first as! UITableViewController
                VC.tableView.scrollToTop(true)
            }
        }
        
        lastViewController = viewController
    }
    
}
