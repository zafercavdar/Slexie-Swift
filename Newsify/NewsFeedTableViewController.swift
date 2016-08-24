//
//  NewsFeedTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

struct FeedPostsPresentation {
    
    struct FeedPostPresentation {
        var owner: String
        var image: UIImage
        var tagList: String
    }
    
    var feedPosts: [FeedPostPresentation] = []
    
    mutating func update(withState state: FeedPostViewModel.State){
        
        feedPosts = state.feedPosts.map({ (feedPost) -> FeedPostPresentation in
            let owner = feedPost.username
            let image = feedPost.photo
            var tagText = ""
            for tag in feedPost.tags{
                tagText += "#\(tag) "
            }
            let tagList = tagText
            return FeedPostPresentation(owner: owner, image: image!, tagList: tagList)
        })
    }
}

class NewsFeedTableViewController: UITableViewController{

    private struct Identifier {
        static let NewsFeedCell = "NewsFeedItemCell"
    }
    
    private var model = FeedPostViewModel()
    private let loadingView = LoadingView()
    private var presentation = FeedPostsPresentation()
    
    @IBOutlet var feedPostsView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadingView.addToView(self.view, text: "Refreshing")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.fetchFeedPosts { 
            self.loadingView.removeFromView(self.view)
        }
        
    }
    
    func applyState(state: FeedPostViewModel.State) {
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: FeedPostViewModel.State.Change) {
        switch change {
        case .posts(let collectionChange):
            presentation.update(withState: model.state)
            switch collectionChange {
            case .reload:
                self.tableView.reloadData()
            }
        case .none:
            break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        
        //tableView.setContentOffset(CGPointZero, animated:true)
        
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        NSLog("\(velocity.y)")
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        model.fetchFeedPosts { 
            refreshControl.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if presentation.feedPosts.count > 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.feedPosts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let feedPresentation = presentation.feedPosts[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.NewsFeedCell, forIndexPath: indexPath) as! NewsFeedItemCell
        
        cell.usernameLabel.text = feedPresentation.owner
        cell.photoView.image = feedPresentation.image
        cell.tagsLabel.text = feedPresentation.tagList
        
        return cell
    }
}
