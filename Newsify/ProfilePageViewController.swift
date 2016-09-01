//
//  ProfilePageViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

struct ProfilePostsPresentation {
    
    struct ProfilePostPresentation {
        var imageID: String
        var image: UIImage
        var tagList: String
        var likers: [String]
        var likeCount: Int
        var liked: Bool
    }
    
    var profilePosts: [ProfilePostPresentation] = []
    
    mutating func update(withState state: ProfilePostViewModel.State){
        
        profilePosts = state.profilePosts.map({ (profilePost) -> ProfilePostPresentation in
            let id = profilePost.id
            let image = profilePost.photo
            var tagList = ""
            for tag in profilePost.tags{
                tagList += "#\(tag) "
            }
            let likers = profilePost.likers
            let likeCount = profilePost.likeCount
            let liked = profilePost.isAlreadyLiked
            return ProfilePostPresentation(imageID: id, image: image!, tagList: tagList, likers: likers, likeCount: likeCount, liked: liked)
        })
    }
}

class ProfilePageViewController: UITableViewController {

    @IBOutlet var profilePostsView: UITableView!
    
    
    private let networkingController = FirebaseController()
    private let model = ProfilePostViewModel()
    private let router = ProfileRouter()
    private var presentation = ProfilePostsPresentation()
    
    private let loadingView = LoadingView()
    
    struct RouteID {
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

        self.applyState(model.state)
        
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
        model.fetchProfilePosts {
            refreshControl.endRefreshing()
        }
    }
    
    private func reload() {
        loadingView.addToView(self.view, text: localized("RefreshingInfo"))
        
        model.fetchProfilePosts { [weak self] in
            
            guard let strongSelf = self else {return}
            strongSelf.loadingView.removeFromView(strongSelf.view)
        }
    }
    
    @IBAction func unwindToProfile(sender: UIStoryboardSegue) {
        reload()
    }

    
    // MARK: TableVC Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.state.profilePosts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let postPresentation = presentation.profilePosts[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.ProfilePostCell, forIndexPath: indexPath) as! ProfilePostTableViewCell
        
        
        cell.profilePostView.image = postPresentation.image
        cell.profilePostTags.text = postPresentation.tagList
        cell.postPresentation.profilePosts = [postPresentation]
        
        cell.tapRecognizer.addTarget(self, action: #selector(photoTapped(_:)))
        cell.tapRecognizer.numberOfTapsRequired = 2
        cell.tapRecognizer.numberOfTouchesRequired = 1
        cell.tapRecognizer.tappedCell = cell
        cell.profilePostView.gestureRecognizers = []
        cell.profilePostView.gestureRecognizers!.append(cell.tapRecognizer)
        
        cell.heartTapRecognizer.tappedCell = cell
        cell.heartTapRecognizer.addTarget(self, action: #selector(heartTapped(_:)))
        cell.heartTapRecognizer.numberOfTapsRequired = 1
        cell.heartTapRecognizer.numberOfTouchesRequired = 1
        cell.heart.gestureRecognizers = []
        cell.heart.gestureRecognizers!.append(cell.heartTapRecognizer)
        
        if postPresentation.liked {
            cell.heart.image = UIImage(named: "Filled Heart")
        } else {
            cell.heart.image = UIImage(named: "Empty Heart")
        }
        
        cell.likeCount.text = String(postPresentation.likeCount)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    func heartTapped(sender: AdvancedGestureRecognizer) {
        let cell = (sender.tappedCell as! ProfilePostTableViewCell)
        let post = cell.postPresentation.profilePosts[0]
        let id = post.imageID
        
        let controller = FirebaseController()
        let uid = controller.getUID()!
        
        // Update view
        if !post.likers.contains(uid){
            model.likePhoto(id)
            
            cell.heart.image = UIImage(named: "Filled Heart")
            cell.postPresentation.profilePosts[0].likers += [uid]
            let count = cell.postPresentation.profilePosts[0].likers.count
            cell.likeCount.text = String(count)
            
            // Send notificitaion
            let notification = Notification(ownerID: uid, targetID: post.imageID, doneByUserID: uid, doneByUsername: "no-need-for-push-notification", type: NotificationType.Liked)
            
            model.pushNotification(notification)
            
        } else {
            model.unlikePhoto(id)
            cell.heart.image = UIImage(named: "Empty Heart")
            cell.postPresentation.profilePosts[0].likers.removeObject(uid)
            let count = cell.postPresentation.profilePosts[0].likers.count
            cell.likeCount.text = String(count)
            
            let notification = Notification(ownerID: uid, targetID: post.imageID, doneByUserID: uid, doneByUsername: "no-need-for-push-notification", type: NotificationType.Liked)
            
            model.removeNotification(notification)
        }
    }

    func photoTapped(sender: AdvancedGestureRecognizer){
        let cell = (sender.tappedCell as! ProfilePostTableViewCell)
        let post = cell.postPresentation.profilePosts[0]
        
        let id = post.imageID
        
        let controller = FirebaseController()
        
        // Update modal
        model.likePhoto(id)
        
        // Update view
        cell.heart.image = UIImage(named: "Filled Heart")
        if !post.likers.contains(controller.getUID()!) {
            cell.likeCount.text = String(post.likeCount + 1)
            cell.postPresentation.profilePosts[0].likers += [controller.getUID()!]
            
            // Send notificitaion
            let notification = Notification(ownerID: controller.getUID()!, targetID: post.imageID, doneByUserID: controller.getUID()!, doneByUsername: "no-need-for-push-notification", type: NotificationType.Liked)
            
            model.pushNotification(notification)
        }


        UIView.animateWithDuration(3.0, delay: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            cell.likedView.alpha = 1
            
            }, completion: {
                (value:Bool) in
                
                cell.likedView.hidden = false
        })
        
        
        UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            
            cell.likedView.alpha = 0
            
            }, completion: {
                (value:Bool) in
                
                cell.likedView.hidden = true
        })
    }

    
}
