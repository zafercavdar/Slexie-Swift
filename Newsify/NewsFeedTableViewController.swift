//
//  NewsFeedTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit


struct PostViewPresentation{
    var postViews: [PostView] = []
    
    mutating func update(withState state: FeedPostViewModel.State){
        postViews = state.feedPosts.map({ (feedPost) -> PostView in
            return PostView(post: feedPost)
        })
    }
}

class NewsFeedTableViewController: UITableViewController{

    private struct Identifier {
        static let NewsFeedCell = "NewsFeedItemCell"
    }
    
    private var model = FeedPostViewModel()
    private let loadingView = LoadingView()
    private var presentation = PostViewPresentation()
    
    @IBOutlet var feedPostsView: UITableView!
    
    var postCount = 3
    let postIncrease = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarItem.title = localized("TabBarHome")
        self.navigationItem.title = localized("NavBarNewsfeed")
        self.tabBarController?.tabBar.items![1].title = localized("TabBarSearch")
        self.tabBarController?.tabBar.items![2].title = localized("TabBarCamera")
        self.tabBarController?.tabBar.items![3].title = localized("TabBarNotifications")
        self.tabBarController?.tabBar.items![4].title = localized("TabBarProfile")

        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.fetchFeedPosts(count: self.postCount, showView: true, completion: { })
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
            case .insertion(let index):
                let indexSet = NSIndexSet(index: index)
                tableView.insertSections(indexSet, withRowAnimation: .Automatic)
            }
        case .loadingView(let text):
            self.loadingView.addToView(self.view, text: text)
        case .removeView:
            self.loadingView.removeFromView(self.view)
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
    
    func refresh(refreshControl: UIRefreshControl) {
        model.fetchFeedPosts(count: postCount, showView: false, completion: {
            refreshControl.endRefreshing()
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return presentation.postViews.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.NewsFeedCell, forIndexPath: indexPath) as! NewsFeedItemCell
        
        let postView = presentation.postViews[indexPath.section]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.contentView.addSubview(postView.cellView)
        
        cell.tapRecognizer.tappedCell = cell
        cell.tapRecognizer.addTarget(self, action: #selector(photoTapped(_:)))
        cell.tapRecognizer.numberOfTapsRequired = 2
        cell.tapRecognizer.numberOfTouchesRequired = 1
        postView.imageView.gestureRecognizers = []
        postView.imageView.addGestureRecognizer(cell.tapRecognizer)
        
        cell.indexPath = indexPath
        cell.heartTapRecognizer.tappedCell = cell
        cell.heartTapRecognizer.addTarget(self, action: #selector(heartTapped(_:)))
        cell.heartTapRecognizer.numberOfTapsRequired = 1
        cell.heartTapRecognizer.numberOfTouchesRequired = 1
        postView.likedView.gestureRecognizers = []
        postView.likedView.addGestureRecognizer(cell.heartTapRecognizer)
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return presentation.postViews[section].headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return presentation.postViews[section].headerView.frame.height
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return presentation.postViews[indexPath.section].cellView.frame.height
    }
    

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.section >= presentation.postViews.count - 1) {
            print("loading more")
            postCount += postIncrease
            model.fetchFeedPosts(count: postCount, showView: false, completion: { })
        }
    }
    
    func heartTapped(sender: AdvancedGestureRecognizer) {
        let cell = (sender.tappedCell as! NewsFeedItemCell)
        let postView = presentation.postViews[cell.indexPath.section]
        let post = postView.post!
        let id = post.id
        
        let controller = FirebaseController()
        let uid = controller.getUID()!
        
        // Update view
        if !post.likers.contains(uid){
            model.likePhoto(id)
            post.isAlreadyLiked = true
            post.likers += [uid]
            postView.updateLikedView()
            postView.updateCountLabel()
            // Send notificitaion
            let notification = Notification(ownerID: post.ownerID, targetID: post.id, doneByUserID: uid, doneByUsername: "no-need-for-push-notification", type: NotificationType.Liked)
            
            model.pushNotification(notification)
            
        } else {
            model.unlikePhoto(id)
            post.isAlreadyLiked = false
            post.likers.removeObject(uid)
            postView.updateCountLabel()
            postView.updateLikedView()
            let notification = Notification(ownerID: post.ownerID, targetID: post.id, doneByUserID: uid, doneByUsername: "no-need-for-push-notification", type: NotificationType.Liked)
            
            model.removeNotification(notification)
        }
    }
    
    func photoTapped(sender: AdvancedGestureRecognizer){
        
        let cell = (sender.tappedCell as! NewsFeedItemCell)
        let index = cell.indexPath.section
        let postView = presentation.postViews[index]
        let post = postView.post!
        let id = post.id
        
        let controller = FirebaseController()
        let uid = controller.getUID()!
        if !post.likers.contains(uid){
            model.likePhoto(id)
            post.isAlreadyLiked = true
            post.likers += [uid]
            postView.updateLikedView()
            postView.updateCountLabel()
            // Send notificitaion
            let notification = Notification(ownerID: post.ownerID, targetID: post.id, doneByUserID: uid, doneByUsername: "no-need-for-push-notification", type: NotificationType.Liked)
            
            model.pushNotification(notification)
            
        }
        UIView.animateWithDuration(3.0, delay: 0.5, options: [], animations: {
            
            self.presentation.postViews[index].heartTapView.alpha = 1
            
            }, completion: {
                (value:Bool) in
                
                self.presentation.postViews[index].heartTapView.hidden = false
        })
        
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: [], animations: {
            
            self.presentation.postViews[index].heartTapView.alpha = 0
            
            }, completion: {
                (value:Bool) in
                
                self.presentation.postViews[index].heartTapView.hidden = true
        })
    }
    
}
