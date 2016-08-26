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
    @IBOutlet weak var logout: UIBarButtonItem!
    
    
    private let networkingController = FirebaseController()
    private let model = ProfilePostViewModel()
    private let router = ProfileRouter()
    private var presentation = ProfilePostsPresentation()
    
    private let loadingView = LoadingView()
    
    struct RouteID {
        static let LogOut = "LogOut"
    }
    
    private struct Identifier {
        static let ProfilePostCell = "ProfilePostTableViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logout.title = preferredLanguage.NavBarLogOut
        
        self.navigationItem.title = preferredLanguage.NavBarProfile
        
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
        loadingView.addToView(self.view, text: preferredLanguage.RefreshingInfo)
        
        model.fetchProfilePosts { [weak self] in
            
            guard let strongSelf = self else {return}
            strongSelf.loadingView.removeFromView(strongSelf.view)
        }
    }

    
    // MARK: Button actions
    
    @IBAction func logOutPressed(sender: UIBarButtonItem) {
        
        networkingController.signOut { [weak self] (Void) in
            guard let strongSelf = self else { return }
            strongSelf.router.routeTo(RouteID.LogOut, VC: strongSelf)
        }
    }
    
    @IBAction func unwindToProfile(sender: UIStoryboardSegue) {
        reload()
    }

    
    // MARK: tableviewcontroller methods
    
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
        cell.id = postPresentation.imageID
        
        cell.tapRecognizer.addTarget(self, action: #selector(photoTapped(_:)))
        cell.tapRecognizer.numberOfTapsRequired = 2
        cell.tapRecognizer.numberOfTouchesRequired = 1
        cell.profilePostView.gestureRecognizers = []
        cell.profilePostView.gestureRecognizers!.append(cell.tapRecognizer)
        cell.tapRecognizer.tappedCell = cell
        
        if postPresentation.liked {
            cell.heart.image = UIImage(named: "Filled Heart")
        } else {
            cell.heart.image = UIImage(named: "Empty Heart")
        }
        
        cell.likeCount.text = String(postPresentation.likeCount)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func photoTapped(sender: AdvancedGestureRecognizer){
        let cell = (sender.tappedCell as! ProfilePostTableViewCell)
        let id = cell.id
        
        let controller = FirebaseController()
        
        model.likePhoto(id)
        
        for profilePost in presentation.profilePosts {
            if profilePost.imageID == id {
                cell.heart.image = UIImage(named: "Filled Heart")
                
                if !profilePost.likers.contains(controller.getUID()!) {
                    cell.likeCount.text = String(profilePost.likeCount + 1)
                }
            }
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
