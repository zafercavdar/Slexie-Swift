//
//  PostContentView.swift
//  Slexie
//
//  Created by Zafer Cavdar on 08/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class PostContentView: UIControl {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var smallHeartView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var bigHeartView: UIImageView!
    
    var post: Post?
    
    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        if self.subviews.count == 0 {
            return loadNib()
        }
        return self
    }
    
    private func loadNib() -> PostContentView {
        
        let view = NSBundle.mainBundle().loadNibNamed("PostContentView", owner: nil, options: nil)[0] as! PostContentView
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]        
        
        return view
    }

    
    func customizeView(post: FeedPost){
        
        self.post = post
        
        let tags = post.tags
        var tagText = ""
        for tag in tags{
            tagText += "#\(tag) "
        }
        
        photoView.image = post.photo!
        photoView.contentMode = .ScaleAspectFit
        photoView.userInteractionEnabled = true
        
        let heart = UIImage(named: "Liked")
        bigHeartView.image = heart
        bigHeartView.contentMode = UIViewContentMode.Center
        bigHeartView.hidden = true
        
        tagsLabel.textColor = UIColor.blackColor()
        tagsLabel.text = tagText
        tagsLabel.textAlignment = .Center
        tagsLabel.font = UIFont.boldSystemFontOfSize(10.00)
        
        smallHeartView.userInteractionEnabled = true
        updateSmallHeart()

        updateCountLabel()
        likeCountLabel.textColor = UIColor.blackColor()
        likeCountLabel.textAlignment = .Center
        likeCountLabel.font = UIFont.boldSystemFontOfSize(11.00)
    }
    
    func updateSmallHeart(){
        let liked = post!.isAlreadyLiked
        var image = UIImage()
        
        image = liked ? UIImage(named: "Filled Heart")! : UIImage(named: "Empty Heart")!
        smallHeartView.image = image
    }
    
    func updateCountLabel(){
        let count = post!.likers.count
        likeCountLabel.text = String(count)
    }
    
}