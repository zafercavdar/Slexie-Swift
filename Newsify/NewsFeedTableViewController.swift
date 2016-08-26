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
        var id: String
        var owner: String
        var image: UIImage
        var tagList: String
        var likers: [String]
        var likeCount: Int
        var liked: Bool
    }
    
    var feedPosts: [FeedPostPresentation] = []
    
    mutating func update(withState state: FeedPostViewModel.State){
        
        feedPosts = state.feedPosts.map({ (feedPost) -> FeedPostPresentation in
            let id = feedPost.id
            let owner = feedPost.username
            let image = feedPost.photo
            var tagText = ""
            for tag in feedPost.tags{
                tagText += "#\(tag) "
            }
            let likers = feedPost.likers
            let tagList = tagText
            let likeCount = feedPost.likeCount
            let liked = feedPost.isAlreadyLiked
            return FeedPostPresentation(id: id, owner: owner, image: image!, tagList: tagList, likers: likers, likeCount: likeCount, liked: liked)
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
        
        self.tabBarItem.title = preferredLanguage.TabBarHome
        self.navigationItem.title = preferredLanguage.NavBarNewsfeed
        self.tabBarController?.tabBar.items![1].title = preferredLanguage.TabBarSearch
        self.tabBarController?.tabBar.items![2].title = preferredLanguage.TabBarCamera
        self.tabBarController?.tabBar.items![3].title = preferredLanguage.TabBarNotifications
        self.tabBarController?.tabBar.items![4].title = preferredLanguage.TabBarProfile


        loadingView.addToView(self.view, text: preferredLanguage.RefreshingInfo)
        
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
        
        cell.id = feedPresentation.id
        cell.usernameLabel.text = feedPresentation.owner
        cell.photoView.image = feedPresentation.image
        cell.tagsLabel.text = feedPresentation.tagList
        cell.likeCount.text = String(feedPresentation.likeCount)
        
        cell.tapRecognizer.addTarget(self, action: #selector(photoTapped(_:)))
        cell.tapRecognizer.numberOfTapsRequired = 2
        cell.tapRecognizer.numberOfTouchesRequired = 1
        cell.photoView.gestureRecognizers = []
        cell.photoView.gestureRecognizers!.append(cell.tapRecognizer)
        cell.tapRecognizer.tappedCell = cell
        
        if feedPresentation.liked {
            cell.heart.image = UIImage(named: "Filled Heart")
        } else {
            cell.heart.image = UIImage(named: "Empty Heart")
        }
        
        cell.likeCount.text = String(feedPresentation.likeCount)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func photoTapped(sender: AdvancedGestureRecognizer){
        let cell = (sender.tappedCell as! NewsFeedItemCell)
        let id = cell.id
        print(id)
        
        let controller = FirebaseController()
        
        model.likePhoto(id)
        
        for feedPost in presentation.feedPosts {
            if feedPost.id == id {
                cell.heart.image = UIImage(named: "Filled Heart")
                
                if !feedPost.likers.contains(controller.getUID()!) {
                    cell.likeCount.text = String(feedPost.likeCount + 1)
                }
            }
        }
        
        UIView.animateWithDuration(3.0, delay: 0.5, options: [], animations: {
            
            cell.likedView.alpha = 1
            
            }, completion: {
                (value:Bool) in
                
                cell.likedView.hidden = false
        })
        
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: [], animations: {
            
            cell.likedView.alpha = 0
            
            }, completion: {
                (value:Bool) in
                
                cell.likedView.hidden = true
        })
    }

}
