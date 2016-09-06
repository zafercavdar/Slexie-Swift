//
//  PostViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

struct SinglePostViewPresentation{

    var postView: PostView?
    
    mutating func update(withState state: SinglePostViewModel.State){
        let post = state.post!
        postView = PostView(post: post)
    }
}


class SinglePostViewController: UITableViewController {
    
    private struct Identifier{
        static let PostViewCell = "PostViewCell"
    }
    
    private struct RouteID {
        static let Back = "Back"
    }
    
    private var backButton = UIBarButtonItem()
    
    private var router = SinglePostViewRouter()
    private var model = SinglePostViewModel()
    private var presentation = SinglePostViewPresentation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonImage = UIImage(named: "backButton")
        backButton = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
    }
    
    func backButtonPressed(sender: UITabBarItem){
        self.router.routeTo(RouteID.Back, VC: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setUIColors()
        setUITitles()
    }
    
    private func setUIColors(){
        tableView.backgroundColor = UIColor.tableBackgroundGray()
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        nav?.tintColor = UIColor.whiteColor()
    }
    
    private func setUITitles(){
        self.navigationController?.navigationController?.title = localized("Photo")
        self.title = localized("Photo")
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if presentation.postView != nil {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.PostViewCell, forIndexPath: indexPath) as! SinglePostViewCell
        
        let postView = presentation.postView!
        
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
        
        cell.heartTapRecognizer.tappedCell = cell
        cell.heartTapRecognizer.addTarget(self, action: #selector(heartTapped(_:)))
        cell.heartTapRecognizer.numberOfTapsRequired = 1
        cell.heartTapRecognizer.numberOfTouchesRequired = 1
        postView.likedView.gestureRecognizers = []
        postView.likedView.addGestureRecognizer(cell.heartTapRecognizer)
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return presentation.postView!.headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return presentation.postView!.headerView.frame.height
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return presentation.postView!.cellView.frame.height
    }
    
    func heartTapped(sender: AdvancedGestureRecognizer) {
        let postView = presentation.postView!
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
        
        let postView = presentation.postView!
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
            
            self.presentation.postView!.heartTapView.alpha = 1
            
            }, completion: {
                (value:Bool) in
                
                self.presentation.postView!.heartTapView.hidden = false
        })
        
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: [], animations: {
            
            self.presentation.postView!.heartTapView.alpha = 0
            
            }, completion: {
                (value:Bool) in
                
                self.presentation.postView!.heartTapView.hidden = true
        })
    }
}
