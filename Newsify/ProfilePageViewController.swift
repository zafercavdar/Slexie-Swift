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
        var image: UIImage
        var tagList: String
    }
    
    var profilePosts: [ProfilePostPresentation] = []
    
    mutating func update(withState state: ProfilePostViewModel.State){
        
        profilePosts = state.profilePosts.map({ (profilePost) -> ProfilePostPresentation in
            let image = profilePost.photo
            var tagText = ""
            for tag in profilePost.tags{
                tagText += "#\(tag) "
            }
            let tagList = tagText
            return ProfilePostPresentation(image: image!, tagList: tagList)
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
        static let LogOut = "LogOut"
        static let Upload = "Upload"
    }
    
    private struct Identifier {
        static let ProfilePostCell = "ProfilePostTableViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        loadingView.addToView(self.view, text: "Refreshing")
        
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
    
    @IBAction func uploadPressed(sender: UIBarButtonItem) {
        self.router.routeTo(RouteID.Upload, VC: self)
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
        
        return cell
    }
    
}
