//
//  TagsTableViewController.swift
//  Newsify
//
//  Created by Zafer Cavdar on 09/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit
import FirebaseAuth

class TagsTableViewController: UITableViewController {
    
    class TagModel {
        var tags: [String] = []
    }

    let model = TagModel()
    let networkingController = FBNetworkingController()
    let router = TagsTableRouter()
    
    private struct Identifier {
        static let TagsTableCell = "TagsTableViewCell"
    }
    
    enum RouteID: String {
        case Upload = "Upload"
        case Cancel = "Cancel"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        model.tags += (UploadViewController.trustedTags)
        
    }
    
    // MARK: Actions
    
    @IBAction func backButton(sender: UIBarButtonItem) {
        self.router.routeTo(RouteID.Cancel.rawValue, VC: self)
    }
    
    @IBAction func uploadData(sender: UIBarButtonItem) {
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: "Uploading")
        
        let photo = UploadViewController.chosenPhoto
        let rate = UploadViewController.compressionRate
        let imageData = UIImageJPEGRepresentation(photo, rate)
        networkingController.uploadPhoto(imageData!, tags: model.tags) { [weak self] (error, photoID, url) in
            
            guard let strongSelf = self else { return }
            
            loadingView.removeFromView(strongSelf.view)
            strongSelf.router.routeTo(RouteID.Upload.rawValue, VC: strongSelf)
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.tags.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tag = model.tags[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.TagsTableCell, forIndexPath: indexPath) as! TagsTableViewCell
        cell.tagsLabel.text = tag
        
        return cell
    }
    
}
