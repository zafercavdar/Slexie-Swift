//
//  Tappable.swift
//  Slexie
//
//  Created by Zafer Cavdar on 25/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

protocol Likeable {
    
    var likedView: UIImageView! {get set}
    var tapRecognizer: AdvancedGestureRecognizer {get set}
    
}

extension Likeable{
    
    func generateLikedView(photoView: UIImageView) -> UIImageView {
    
        var resultView: UIImageView
        let image = UIImage(named: "Liked")
        let newImage = resizeImage(image!, newWidth: 100)
        
        let imageMidX = (UIScreen.mainScreen().bounds.width - newImage.size.width) / 2
        let imageMidY = photoView.center.y - newImage.size.height/2
        
        resultView = UIImageView(frame: CGRect(x: imageMidX, y: imageMidY, width: newImage.size.width, height: newImage.size.height))
        resultView.image = newImage
        resultView.contentMode = UIViewContentMode.Center
        resultView.hidden = true
        
        return resultView
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}