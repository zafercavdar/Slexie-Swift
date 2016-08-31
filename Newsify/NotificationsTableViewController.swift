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
    var controller = FirebaseController()
    
    mutating func update(withState state: NotificationsViewModel.State){
        
        notifications = state.notifs.map({ (notif) -> NotificationPresentation in
            
            let who = notif.notificationDoneByUsername
            var actionString = ""
            
            switch notif.notificationType {
            case .Liked:
                actionString = preferredLanguage.NotifyLikeAction
            case .Commented:
                actionString = preferredLanguage.NotifyCommentAction
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

    private var model = NotificationsViewModel()
    private let loadingView = LoadingView()
    private var presentation = NotificationsPresentation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = preferredLanguage.NavBarNotifications
        
        loadingView.addToView(self.view, text: preferredLanguage.RefreshingInfo)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        model.fetchNotifications {
            self.loadingView.removeFromView(self.view)
        }
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        model.fetchNotifications {
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
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
}

extension Language {

    var NotifyLikeAction: String {
        switch self {
        case .Turkish:
            return " fotoğrafını beğendi."
        case .English:
            return " has liked your photo."
        case .Russian:
            return " любил свою фотографию."
        }
    }
    
    var NotifyCommentAction: String {
        switch self {
        case .Turkish:
            return " fotoğrafına yorum yaptı."
        case .English:
            return " has commented on your photo."
        case .Russian:
            return " прокомментировал вашу фотографию."
        }
    }
}
