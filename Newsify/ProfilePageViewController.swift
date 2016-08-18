//
//  ProfilePageViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePageViewController: UIViewController {

    let networkingController = FBNetworkingController()
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        networkingController.signOut { (Void) in
            self.performSegueWithIdentifier("LogOut", sender: nil)
        }
    }
    
    @IBAction func upload(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("TakeSnap", sender: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        let nav = self.navigationController?.navigationBar
        
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
        
        
        super.viewWillAppear(animated)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
