//
//  ProfilePageViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

struct ProfilePostViewPresentation {
    
    var postViews: [PostView] = []
    
    mutating func update(withState state: ProfilePostViewModel.State){
        postViews = state.profilePosts.map({ (profilePost) -> PostView in
            return PostView(post: profilePost)
        })
    }

}

class ProfilePageViewController: UITableViewController {

    @IBOutlet var profilePostsView: UITableView!
    
    
    private let networkingController = FirebaseController()
    private let model = ProfilePostViewModel()
    private let router = ProfileRouter()
    private var presentation = ProfilePostViewPresentation()
    
    private let loadingView = LoadingView()
    
    struct RouteID {
        static let Setting = "Settings"
    }
    
    private struct Identifier {
        static let ProfilePostCell = "ProfilePostTableViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = localized("NavBarProfile")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        //self.applyState(model.state)
        
        self.model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        reload()
        
    }
    
    func applyState(state: ProfilePostViewModel.State) {
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: ProfilePostViewModel.State.Change) {
        switch change {
        case .posts(let collectionChange):
            presentation.update(withState: model.state)
            switch collectionChange {
            case .reload:
                self.tableView.reloadData()
            }
        case .loadingView(let text):
            loadingView.addToView(self.view, text: text)
        case .removeView:
            loadingView.removeFromView(self.view)
        case .none:
            break
        }
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

        let nav = self.navigationController?.navigationBar
        
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        model.fetchProfilePosts(false, completion: {
            refreshControl.endRefreshing()
        })
    }
    
    private func reload() {
        model.fetchProfilePosts(true) {
        
        }
    }
    
    @IBAction func unwindToProfile(sender: UIStoryboardSegue) {
        reload()
    }
    
    @IBAction func settingsPressed(sender: UIBarButtonItem) {
        self.router.routeTo(RouteID.Setting, VC: self)
    }

    
    // MARK: TableVC Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return presentation.postViews.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.ProfilePostCell, forIndexPath: indexPath) as! ProfilePostTableViewCell
        
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

    
    func heartTapped(sender: AdvancedGestureRecognizer) {
        let cell = (sender.tappedCell as! ProfilePostTableViewCell)
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
        
        let cell = (sender.tappedCell as! ProfilePostTableViewCell)
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
