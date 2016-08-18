//
//  ProfilePageViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePageViewController: UITableViewController {

    let networkingController = FBNetworkingController()
    let model = ProfilePostViewModel()
    
    @IBOutlet var profilePostsView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.fetchProfilePosts { 
            self.profilePostsView.reloadData()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let nav = self.navigationController?.navigationBar
        
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
        
        
        super.viewWillAppear(animated)
    }
    
    // MARK: Button actions
    
    @IBAction func logOutPressed(sender: UIBarButtonItem) {
        
        networkingController.signOut { (Void) in
            self.performSegueWithIdentifier("LogOut", sender: nil)
        }
    }
    
    @IBAction func uploadPressed(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("TakeSnap", sender: nil)
    }

    
    // MARK: tableviewcontroller methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.profilePosts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "ProfilePostTableViewCell"
        let profileItem = model.profilePosts[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ProfilePostTableViewCell
        
        
        cell.profilePostView.image = profileItem.photo
        
        var tagText = ""
        for tag in profileItem.tags{
            tagText += "#\(tag) "
        }
        
        cell.profilePostTags.text = tagText
        
        return cell
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
