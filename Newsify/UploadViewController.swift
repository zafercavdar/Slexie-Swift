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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        UploadViewController.compressionRate = CGFloat(slider.value / 100.00)
        compressionLabel.text = String(Int(slider.value))
        
    }
    
    @IBAction func searchButtonPressed(sender: UIButton) {
        
        let loadingView = LoadingView()
        loadingView.addToView(self.view, text: "Uploading")
        
        if let imageData = UIImageJPEGRepresentation(UploadViewController.chosenPhoto, UploadViewController.compressionRate) {
            imaggaService.uploadPhotoGetContentID(imageData, completion: { (id) in
                
                UploadViewController.contentID = id
                
                loadingView.changeText("Analyzing")
                self.imaggaService.findRelatedTagsWith(contentID: id, completion: { (tags) in
                    UploadViewController.trustedTags = tags
                    loadingView.removeFromView(self.view)
                    self.performSegueWithIdentifier("ShowTags", sender: nil)

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
    
    @IBAction func logOut(sender: UIButton) {
        networkingController.signOut { (Void) in }
        performSegueWithIdentifier("LogoutReturnToLogin", sender: nil)
    }
  
    
    // MARK: Helper Methods
    // Will not be used anymore
    func wait()
    {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 1))
    }
    
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


extension UIImage {
    func resizeWithPercentage(percentage: CGFloat) -> UIImage?{
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

