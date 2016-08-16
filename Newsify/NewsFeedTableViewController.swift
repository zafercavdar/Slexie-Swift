//
//  NewsFeedTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit
import Foundation

func += <K, V> (inout left: Dictionary <K,V> , right: Dictionary <K,V>) {
    for (k, v) in right {
        left[k] = v
    }
}

class NewsFeedTableViewController: UITableViewController {

    var feedItems: [FeedItem] = []
    let networkingController = FBNetworkingController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let defaultImage = UIImage(named: "example1")
        let defaultUsername = "jane"
        let defaultTags = ["food","spoon", "wood"]
        
        let defaultImage2 = UIImage(named: "example2")
        let defaultUsername2 = "michael"
        let defaultTags2 = ["friends","fun", "together"]
        
        
        let feedItem = FeedItem(username: defaultUsername, photo: defaultImage!, tags: defaultTags)
        let feedItem2 = FeedItem(username: defaultUsername2, photo: defaultImage2!, tags: defaultTags2)

        feedItems = [feedItem,feedItem2]
        
        var posts: [String: String] = [:]
        
        networkingController.getAccountTags { (tags) in
            for tag in tags {
                self.networkingController.getPhotosRelatedWith(tag, completion: { (photoToUser) in
                    posts += photoToUser
                })
            }
            print(posts)
        }
        
        
        
    }

    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "NewsFeedItemCell"
        let feedItem = feedItems[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! NewsFeedItemCell
        
        cell.usernameLabel.text = feedItem.username
        cell.photoView.image = feedItem.photo
        
        var tagText = ""
        for tag in feedItem.tags{
            tagText += "#\(tag) "
        }
        
        cell.tagsLabel.text = tagText
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
