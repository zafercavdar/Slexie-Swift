//
//  SearchPageTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit


struct SearchPostsPresentation {
    
    struct SearchPostPresentation {
        var id: String
        var ownerName: String
        var ownerID: String
        var image: UIImage
        var tagList: String
        var likers: [String]
        var likeCount: Int
        var liked: Bool
    }
    
    var searchPosts: [SearchPostPresentation] = []
    
    mutating func update(withState state: SearchPostViewModel.State){
        
        searchPosts = state.searchPosts.map({ (searchPost) -> SearchPostPresentation in
            let id = searchPost.id
            let ownerName = searchPost.ownerUsername
            let ownerID = searchPost.ownerID
            let image = searchPost.photo
            var tagText = ""
            for tag in searchPost.tags{
                tagText += "#\(tag) "
            }
            let tagList = tagText
            let likers = searchPost.likers
            let likeCount = searchPost.likeCount
            let liked = searchPost.isAlreadyLiked
            return SearchPostPresentation(id: id, ownerName: ownerName, ownerID: ownerID, image: image!, tagList: tagList, likers: likers, likeCount: likeCount, liked: liked)
        })
    }
}

struct SearchPostViewPresentation{
    var postViews: [PostView] = []
    
    mutating func update(withState state: SearchPostViewModel.State){
        postViews = state.searchPosts.map({ (feedPost) -> PostView in
            return PostView(post: feedPost)
        })
    }
}


class SearchPageTableViewController: UITableViewController, UISearchResultsUpdating {
    
    private struct Identifier {
        static let SearchFeedCell = "SearchFeedItemCell"
    }
    
    private var model = SearchPostViewModel()
    private var presentation = SearchPostViewPresentation()

    var searchController = UISearchController(searchResultsController: nil)
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "\(localized("TabBarSearch")) ..."
        
        searchController.searchBar.setValue(localized("Cancel"), forKey: "_cancelButtonText")
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = localized("NavBarSearch")
        
        self.definesPresentationContext = true
        configureSearchController()

        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(animated)
        let nav = self.navigationController?.navigationBar
        
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        
    }
    
    // MARK: State functions
    
    func applyState(state: SearchPostViewModel.State) {
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: SearchPostViewModel.State.Change) {
        switch change {
        case .posts(let collectionChange):
            presentation.update(withState: model.state)
            switch collectionChange {
            case .reload:
                self.tableView.reloadData()
            default:
                break
            }
        case .none:
            break
        }
    }
    
    // MARK: Search Bar actions
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //model.cleanSearchPosts()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        model.cleanSearchPosts()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text?.lowercaseString
        
        if searchString?.characters.count >= 3 {
            model.fetchSearchPosts(searchString!) { }
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return presentation.postViews.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.SearchFeedCell, forIndexPath: indexPath) as! SearchFeedItemCell
        
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
        let postView = presentation.postViews[section]
        postView.moreButton.index = section
        postView.moreButton.addTarget(self, action: #selector(moreButtonClicked), forControlEvents: .TouchDown)
        
        return presentation.postViews[section].headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return presentation.postViews[section].headerView.frame.height
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return presentation.postViews[indexPath.section].cellView.frame.height
    }
    
    func moreButtonClicked(sender: ButtonWithIndex){
        let index = sender.index!
        let id = presentation.postViews[index].post!.id
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Report", style: .Destructive , handler:{ (action)in
            
            let alertController = UIAlertController(title: "Report Photo?", message: nil, preferredStyle: .Alert)
            
            let noAction = UIAlertAction(title: localized("Cancel"), style: .Cancel, handler: nil)
            
            let yesAction = UIAlertAction(title: localized("Report"), style: .Destructive, handler: { (action: UIAlertAction!) in
                
                self.model.reportPost(id)
                
            })
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            alertController.view.tintColor = UIColor.flatBlue()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func heartTapped(sender: AdvancedGestureRecognizer) {
        let cell = (sender.tappedCell as! SearchFeedItemCell)
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
        
        let cell = (sender.tappedCell as! SearchFeedItemCell)
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
