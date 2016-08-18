//
//  SearchViewController.swift
//  Newsify
//
//  Created by Zafer Cavdar on 07/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit
import FirebaseAuth
import Alamofire

class UploadViewController: UIViewController, UINavigationControllerDelegate {
    
    static var contentID = ""
    static var chosenPhoto = UIImage()
    static var compressionRate = CGFloat(0.5)
    static var trustedTags: [String] = []
    static var trustedBackColor = "null"
    
    let networkingController = FBNetworkingController()
    let imaggaService = PhotoAnalyzeService()
    let router = UploadViewRouter()
    
    enum RouteID: String {
        case ShowTags = "ShowTags"
        case Dismiss = "Dismiss"
    }
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var compressionLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var hiLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UploadViewController.chosenPhoto = photoImageView.image!
        
        if let email = networkingController.getCurrentUser()?.email {
            
            if let indexOfAt = indexOf(email, substring: "@"){
                let distance = email.startIndex.advancedBy(indexOfAt)
                let username = email.substringToIndex(distance)
                hiLabel.text = "Hi \(username)"
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        UploadViewController.compressionRate = CGFloat(slider.value / 100.00)
        compressionLabel.text = String(Int(slider.value))
        
    }
    
    @IBAction func returnToProfile(sender: UIButton) {
        self.router.routeTo(RouteID.Dismiss.rawValue, VC: self)
    }
    
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: "Analyzing")
        
        if let imageData = UIImageJPEGRepresentation(UploadViewController.chosenPhoto, UploadViewController.compressionRate) {
            imaggaService.uploadPhotoGetContentID(imageData, completion: { [weak self] (id) in
                
                UploadViewController.contentID = id
                guard let strongSelf = self else { return }
                
                strongSelf.imaggaService.findRelatedTagsWith(contentID: id, completion: { [weak self] (tags) in
                    UploadViewController.trustedTags = tags
                    
                    guard let sself = self else {return}
                    
                    loadingView.removeFromView(sself.view)
                    sself.router.routeTo(RouteID.ShowTags.rawValue, VC: sself)
                })
                
            })
        }
    }
    
    @IBAction func fromLibrary(sender: UISwipeGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func fromCamera(sender: UISwipeGestureRecognizer) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .Camera
        imagePickerController.delegate = self
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: Helper Methods
    // Will not be used anymore
    
    func indexOf(source: String, substring: String) -> Int? {
        let maxIndex = source.characters.count - substring.characters.count
        for index in 0...maxIndex {
            let rangeSubstring = source.startIndex.advancedBy(index)..<source.startIndex.advancedBy(index + substring.characters.count)
            if source.substringWithRange(rangeSubstring) == substring {
                return index
            }
        }
        return nil
    }
    
    func wait()
    {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 1))
    }
    
}

extension UploadViewController : UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        photoImageView.image = selectedImage
        UploadViewController.chosenPhoto = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
    }
}
