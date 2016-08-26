//
//  CameraTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

struct ImagePresentation {
    
    var imageData = NSData()
    var tags: [String] = []
    var userTags: [String] = []

    private var manuelTagsRemained = 5
    
    mutating func update(withState state: CameraViewModel.State){
        imageData = state.post.imageData
        tags = state.post.trustedTags
        userTags = state.post.userTags
    }
    
    func totalTagCount() -> Int{
        return tags.count + userTags.count
    }
    
}

class CameraTableViewController: UITableViewController, UINavigationControllerDelegate {

    
    private struct Identifier {
        static let TagsTableCell = "TagsTableViewCell"
    }
    
    struct RouteID {
        static let Upload = "Upload"
        static let toFeed = "toFeed"
        static let Dismiss = "Dismiss"
    }
    
    
    private let networkingController = FirebaseController()
    private let router = CameraRouter()
    private let loadingView = LoadingView()
    private let model = CameraViewModel()
    private var presentation = ImagePresentation()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = preferredLanguage.NavBarTags

        
        self.applyState(model.state)
        
        model.stateChangeHandler = { [weak self] change in
            self?.applyStateChange(change)
        }
        
        callCameraController()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if self.tabBarController?.selectedIndex != 2 {
            callCameraController()
        }
        
        super.viewWillAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor.coreColor()
        nav?.barStyle = UIBarStyle.BlackOpaque

    }
    
    func applyState(state: CameraViewModel.State) {
        presentation.update(withState: state)
        self.tableView.reloadData()
    }
    
    func applyStateChange(change: CameraViewModel.State.Change) {
        switch change {
        case .tags(let collectionChange):
            presentation.update(withState: model.state)
            switch collectionChange {
            case .reload:
                self.tableView.reloadData()
            }
        case .none:
            break
        }
    }
    
    private func callCameraController() {
        let imagePickerController = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePickerController.sourceType = .Camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            presentViewController(imagePickerController, animated: true, completion: nil)
            
        } else {
            cameraNotAvailable()
        }

    }
    
    private func uploadData() {
        
        loadingView.addToView(self.view, text: preferredLanguage.Uploading)
        
        let imageData = presentation.imageData
        let tags = presentation.tags + presentation.userTags
        
        networkingController.uploadPhoto(imageData, tags: tags) { [weak self] (error, photoID, url) in
            
            guard let strongSelf = self else { return }
            
            if error == nil {
                _ = NSTimer.scheduledTimerWithTimeInterval(2, target: strongSelf, selector: #selector(strongSelf.callRouter), userInfo: nil, repeats: false)

            }
        }
        
    }
    
    @objc private func callRouter(){
        loadingView.removeFromView(self.view)
        self.router.routeTo(RouteID.Upload, VC: self)
    }
    
    // MARK: Actions
    
    @IBAction func uploadPressed(sender: UIBarButtonItem) {
        uploadData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.totalTagCount()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        var tag: String
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.TagsTableCell, forIndexPath: indexPath) as! TagsTableViewCell
        
        if row >= presentation.tags.count {
            tag = presentation.userTags[row - presentation.tags.count]
            cell.tagLabel.textColor = UIColor.blueColor()
        } else {
            tag = presentation.tags[indexPath.row]
            cell.tagLabel.textColor = UIColor.blackColor()
        }
        
        cell.tagLabel.text = "#\(tag)"
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let row = indexPath.row
            if row >= presentation.tags.count {
                model.removeTagByUser(at: row - presentation.tags.count)
                presentation.manuelTagsRemained += 1
            } else {
                model.removeAutoTag(at: row)
            }
            
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    @IBAction func addTag(sender: UIBarButtonItem) {
        addManuelTag()
    }
    func addManuelTag(){
        if presentation.manuelTagsRemained != 0{
            
            let alert = UIAlertController(
                title: "Add a tag",
                message: "You can add \(self.presentation.manuelTagsRemained) more tags",
                preferredStyle: .Alert
            )
            
            alert.addTextFieldWithConfigurationHandler { (field) in
                field.placeholder = "Name"
            }
            
            let addAction = UIAlertAction(title: "Add", style: .Default) { [weak self] (action) in
                
                guard let strongSelf = self,
                    fields = alert.textFields,
                    name = fields[0].text
                    else { return }
                
                strongSelf.presentation.manuelTagsRemained -= 1
                strongSelf.model.addTagByUser(name.lowercaseString)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
}

extension CameraTableViewController : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        model.resetImage()
        
        self.router.routeTo(RouteID.Dismiss, VC: self)
        self.router.routeTo(RouteID.toFeed, VC: self)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var takenPhoto = UIImage()
        
        if picker.sourceType == .Camera {
            takenPhoto = info[UIImagePickerControllerEditedImage] as! UIImage
        } else if picker.sourceType == .PhotoLibrary {
            takenPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        
        self.router.routeTo(RouteID.Dismiss, VC: self)
        
        loadingView.addToView(self.view, text: "Analyzing")
        
        model.fetchImageTags(takenPhoto) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.loadingView.removeFromView(strongSelf.view)
        }
    }
}

extension Language {
    
    var Uploading: String {
        switch self {
        case .Turkish:
            return "Yükleniyor"
        case .English:
            return "Uploading"
        case .Russian:
            return "Выгрузка"
        }
    }
}
