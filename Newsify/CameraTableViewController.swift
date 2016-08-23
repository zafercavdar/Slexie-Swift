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
    
    mutating func update(withState state: CameraViewModel.State){
        imageData = state.post.imageData
        tags = state.post.trustedTags
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
        
        loadingView.addToView(self.view, text: "Uploading")
        
        let imageData = presentation.imageData
        let tags = presentation.tags
        
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
        return presentation.tags.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tag = presentation.tags[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.TagsTableCell, forIndexPath: indexPath) as! TagsTableViewCell
        
        cell.tagLabel.text = tag
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            presentation.tags.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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

