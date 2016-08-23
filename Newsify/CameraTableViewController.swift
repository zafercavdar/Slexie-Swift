//
//  CameraTableViewController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class CameraTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    struct Image {
        var contentID: String = ""
        var image: UIImage = UIImage()
        let compressionRate = CGFloat(0.5)
        var trustedTags: [String] = []
    }
    
    private struct Identifier {
        static let TagsTableCell = "TagsTableViewCell"
    }
    
    struct RouteID {
        static let Upload = "Upload"
    }
    
    var post = Image()
    
    private let imaggaService = ImaggaService()
    private let networkingController = FirebaseController()
    private let router = CameraRouter()
    private let loadingView = LoadingView()


    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    private func analyzeImage() {
        loadingView.addToView(self.view, text: "Analyzing")
        
        if let imageData = UIImageJPEGRepresentation(post.image, post.compressionRate) {
            imaggaService.uploadPhotoGetContentID(imageData, completion: { [weak self] (id) in
                
                guard let strongSelf = self else { return }
                
                strongSelf.post.contentID = id
                
                strongSelf.imaggaService.findRelatedTagsWith(contentID: id, completion: { [weak self] (tags) in
                    
                    guard let sself = self else {return}
                    sself.post.trustedTags = tags
                    sself.loadingView.removeFromView(sself.view)
                    sself.tableView.reloadData()
                    })
                
                })
        }
    }
    
    private func uploadData() {
        
        loadingView.addToView(self.view, text: "Uploading")
        
        let photo = post.image
        let rate =  post.compressionRate
        let imageData = UIImageJPEGRepresentation(photo, rate)
        
        networkingController.uploadPhoto(imageData!, tags: post.trustedTags) { [weak self] (error, photoID, url) in
            
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
        return post.trustedTags.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tag = post.trustedTags[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.TagsTableCell, forIndexPath: indexPath) as! TagsTableViewCell
        cell.tagLabel.text = tag
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            post.trustedTags.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}

extension CameraTableViewController : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImage = UIImage()
        
        if picker.sourceType == .Camera {
            selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        } else if picker.sourceType == .PhotoLibrary {
            selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        }
        
        post.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
        analyzeImage()
    }
}

