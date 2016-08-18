//
//  NewsFeedTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit
import Foundation

class NewsFeedTableViewController: UITableViewController {

    var model = FeedPostViewModel()
    let loadingView = LoadingView()
    
    @IBOutlet var feedPostsView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.addToView(self.view, text: "Refreshing")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        model.fetchFeedPosts { 
            self.loadingView.removeFromView(self.view)
            self.feedPostsView.reloadData()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        //nav?.tintColor = UIColor.whiteColor()
       
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        model.fetchFeedPosts { 
            self.feedPostsView.reloadData()
            refreshControl.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if model.feedPosts.count > 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.feedPosts.count
    }

    // presentation
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "NewsFeedItemCell"
        let feedItem = model.feedPosts[indexPath.row]
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
}
