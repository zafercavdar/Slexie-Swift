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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    @IBAction func logOutButtonPressed(sender: UIButton) {
        networkingController.signOut { (Void) in }
        self.performSegueWithIdentifier("LogOut", sender: nil)
    }
    
    @IBAction func uploadButtonPressed(sender: UIButton) {
        self.performSegueWithIdentifier("TakeSnap", sender: nil)
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
