//
//  ProfilePageViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePageViewController: UITableViewController {

    @IBOutlet var profilePostsView: UITableView!
    
    let networkingController = FBNetworkingController()
    let model = ProfilePostViewModel()
    let loadingView = LoadingView()
    
    let router = ProfileRouter()
    
    enum RouteID: String {
        case LogOut = "LogOut"
        case Upload = "Upload"
    }
    
    private struct Identifier {
        static let ProfilePostCell = "ProfilePostTableViewCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)

        
        reload()
        
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
            self.profilePostsView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    private func reload() {
        loadingView.addToView(self.view, text: "Refreshing")
        
        model.fetchProfilePosts { [weak self] in
            
            guard let strongSelf = self else {return}
            
            strongSelf.profilePostsView.reloadData()
            strongSelf.loadingView.removeFromView(strongSelf.view)
        }
    }

    
    // MARK: Button actions
    
    @IBAction func logOutPressed(sender: UIBarButtonItem) {
        
        networkingController.signOut { [weak self] (Void) in
            guard let strongSelf = self else { return }
            strongSelf.router.routeTo(RouteID.LogOut.rawValue, VC: strongSelf)
        }
    }
    
    @IBAction func uploadPressed(sender: UIBarButtonItem) {
        self.router.routeTo(RouteID.Upload.rawValue, VC: self)
    }
    
    @IBAction func unwindToProfile(sender: UIStoryboardSegue) {
        reload()
    }

    
    // MARK: tableviewcontroller methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.profilePosts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let profileItem = model.profilePosts[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.ProfilePostCell, forIndexPath: indexPath) as! ProfilePostTableViewCell
        
        
        cell.profilePostView.image = profileItem.photo
        
        var tagText = ""
        for tag in profileItem.tags{
            tagText += "#\(tag) "
        }
        
        cell.profilePostTags.text = tagText
        
        return cell
    }
    
}
