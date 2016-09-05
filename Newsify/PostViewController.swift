//
//  PostViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class PostViewController: UITableViewController {

    private var postView: PostView?
    
    private struct Identifier{
        static let PostViewCell = "PostViewCell"
    }
    
    private struct RouteID {
        static let Back = "Back"
    }
    
    private var backButton = UIBarButtonItem()
    
    private var router = PostViewRouter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultImage = UIImage(named: "example2")
        let defaultTags = "#friends #fun #together"
        
        let feedPostPresentation = FeedPostPresentation(id: "20160905SS141313UUasdASD", ownerName: "zafercavdar", ownerID: "asdASD", image: defaultImage!, tagList: defaultTags, likers: [], likeCount: 0, liked: false)
        
        postView = PostView(post: feedPostPresentation)
        
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.PostViewCell, forIndexPath: indexPath) as! PostViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.contentView.addSubview(postView!.cellView)
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return postView!.footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return postView!.footerView.frame.height
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return postView!.headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return postView!.headerView.frame.height
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return postView!.cellView.frame.height
    }

}
