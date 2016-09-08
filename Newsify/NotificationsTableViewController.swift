//
//  NotificationsTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

struct NotificationsPresentation {

    struct NotificationPresentation{
        let who: String
        let actionString: String
        let target: String
        let targetImage: UIImage
    }
    
    var notifications: [NotificationPresentation] = []
    var badgeValue = 0
    
    mutating func update(withState state: NotificationsViewModel.State){
        
        badgeValue = state.notifs.count - notifications.count
        
        notifications = state.notifs.map({ (notif) -> NotificationPresentation in
            
            let who = notif.notificationDoneByUsername
            var actionString = ""
            
            switch notif.notificationType {
            case .Liked:
                actionString = localized("NotifyLikeAction")
            case .Commented:
                actionString = localized("NotifyCommentAction")
            case .Null:
                actionString = notif.notificationType.actionString
            }
            
            let target = notif.notificationTargetID
            let image = notif.targetImage
            
            return NotificationPresentation(who: who, actionString: actionString, target: target, targetImage: image)
            
        })
    }
}


class NotificationsTableViewController: UITableViewController {
    
    private struct Identifier {
        static let NotificationCell = "NotificationCell"
    }
    
    private struct RouteID{
        static let DetailedSinglePost = "DetailedSinglePost"
    }

    private var model = NotificationsViewModel()
    private let loadingView = LoadingView()
    private var presentation = NotificationsPresentation()
    private let router = NotificationsRouter()
    var selectedPost: FeedPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = localized("NavBarNotifications")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        tableView.tableFooterView = view
        
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        model.fetchNotifications(false) {
            refreshControl.endRefreshing()
        }
    }

    
    func applyState(state: NotificationsViewModel.State) {
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: NotificationsViewModel.State.Change) {
        switch change {
        case .notifications(let collectionChange):
            presentation.update(withState: model.state)
            switch collectionChange {
            case .reload:
                self.tableView.reloadData()
                //if presentation.badgeValue > 0 {
                    self.tabBarItem.badgeValue = String(presentation.badgeValue)
                //}
                self.tabBarItem = self.tabBarItem
            default:
                break
            }
        case .loading(let loadingState):
            if loadingState.needsUpdate {
                if loadingState.isActive {
                    self.loadingView.addToView(self.view, text: localized("RefreshingInfo"))
                } else {
                    self.loadingView.removeFromView(self.view)
                }
            }

        case .postProduced(let post):
            selectedPost = post
            router.routeTo(RouteID.DetailedSinglePost, VC: self)
        case .none:
            break
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque
        
        model.fetchNotifications(true) {
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.notifications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let notifPresentation = presentation.notifications[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.NotificationCell, forIndexPath: indexPath) as! NotificationTableViewCell
        
        cell.notifLabel.text = notifPresentation.who + notifPresentation.actionString
        cell.targetImageView.image = notifPresentation.targetImage
        cell.targetImageView.center = CGPointMake(cell.targetImageView.center.x, cell.contentView.bounds.size.height/2)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let notif = presentation.notifications[index]
        let postID = notif.target
        if notif.who != ""{
            model.detailedInfoAboutPost(postID)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "DetailedSinglePost"){
            let singlePostViewController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! SinglePostViewController
            singlePostViewController.model.updatePost(selectedPost!)
        }
    }
}