//
//  PostView.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ButtonWithIndex: UIButton {
    var index: Int?
}

class PostView {

    var headerView = UIView() // username
    var moreButton = ButtonWithIndex()
    
    var cellView = UIView() // image and tags
    var heartTapView = UIImageView()
    var imageView = UIImageView()
    
    var footerView = UIView() // like button + count
    var likedView = UIImageView()
    var countLabel = UILabel()
    
    
    var post: FeedPost? = nil
    
    init(post: FeedPost){
    
        self.post = post
        
        createHeaderView()
        createCellView()
    }
    
    private func createHeaderView(){
        let username = post?.ownerUsername
        let width = UIScreen.mainScreen().bounds.size.width
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        headerView.backgroundColor = UIColor.whiteColor()
        
        let usernameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        usernameLabel.textColor = UIColor.blackColor()
        usernameLabel.text = username
        usernameLabel.textAlignment = .Center
        usernameLabel.font = UIFont.boldSystemFontOfSize(16.00)
        usernameLabel.center = headerView.center
        headerView.addSubview(usernameLabel)
        
        moreButton = ButtonWithIndex(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 30, y: 0, width: 30, height: 30))
        moreButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        moreButton.setTitle("...", forState: .Normal)
        moreButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16.00)
        moreButton.center.y = headerView.center.y
        headerView.addSubview(moreButton)
        
    }
    
    private func createCellView(){
        let image = post!.photo
        let tags = post!.tags
        var tagText = ""
        for tag in tags{
            tagText += "#\(tag) "
        }

        let width = UIScreen.mainScreen().bounds.size.width

        cellView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width + 30 + 54))
        cellView.userInteractionEnabled = true
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
        imageView.userInteractionEnabled = true
        cellView.addSubview(imageView)
        
        let heart = UIImage(named: "Liked")
        let newImage = UIImage.resizeImage(heart!, newWidth: 100)
        let imageMidX = (UIScreen.mainScreen().bounds.width - newImage.size.width) / 2
        let imageMidY = imageView.center.y - newImage.size.height/2
        heartTapView = UIImageView(frame: CGRect(x: imageMidX, y: imageMidY, width: newImage.size.width, height: newImage.size.height))
        heartTapView.image = newImage
        heartTapView.contentMode = UIViewContentMode.Center
        heartTapView.hidden = true
        cellView.addSubview(heartTapView)
        
        let tagsLabel = UILabel(frame: CGRect(x: 0, y: imageView.frame.height, width: width, height: 30))
        tagsLabel.textColor = UIColor.blackColor()
        tagsLabel.text = tagText
        tagsLabel.textAlignment = .Center
        tagsLabel.font = UIFont.boldSystemFontOfSize(10.00)
        tagsLabel.center.x = cellView.center.x
        cellView.addSubview(tagsLabel)
        
        let offSet = 0.0
        let gap = 0.0
        let imageWidth = 44.0
        let labelWidth = 10.0
        
        likedView = UIImageView(frame: CGRect(x: (Double(width) - imageWidth - gap - labelWidth)/2, y: Double(imageView.frame.height) + offSet + 30, width: imageWidth, height: imageWidth))
        likedView.userInteractionEnabled = true
        updateLikedView()
        cellView.addSubview(likedView)
        
        countLabel = UILabel(frame: CGRect(x: (Double(width) + imageWidth + gap)/2, y: Double(imageView.frame.height) + offSet + 30, width: labelWidth, height: imageWidth))
        updateCountLabel()
        countLabel.textColor = UIColor.blackColor()
        countLabel.textAlignment = .Center
        countLabel.font = UIFont.boldSystemFontOfSize(11.00)
        countLabel.center.y = likedView.center.y
        cellView.addSubview(countLabel)
    }
    
    private func createFooterView(){
        let width = Double(UIScreen.mainScreen().bounds.size.width)
        
        let offSet = 0.0
        let gap = 0.0
        let imageWidth = 44.0
        let labelWidth = 10.0

        footerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 54))
        footerView.userInteractionEnabled = true
        footerView.backgroundColor = UIColor.whiteColor()
        
        likedView = UIImageView(frame: CGRect(x: (width - imageWidth - gap - labelWidth)/2, y: offSet, width: imageWidth, height: imageWidth))
        likedView.userInteractionEnabled = true
        updateLikedView()
        footerView.addSubview(likedView)
        
        countLabel = UILabel(frame: CGRect(x: (width + imageWidth + gap)/2, y: offSet, width: labelWidth, height: imageWidth))
        updateCountLabel()
        countLabel.textColor = UIColor.blackColor()
        countLabel.textAlignment = .Center
        countLabel.font = UIFont.boldSystemFontOfSize(11.00)
        countLabel.center.y = footerView.center.y
        footerView.addSubview(countLabel)
    }
    
    func updateLikedView(){
        let liked = post!.isAlreadyLiked
        var image = UIImage()
        
        image = liked ? UIImage(named: "Filled Heart")! : UIImage(named: "Empty Heart")!
        likedView.image = image
    }
    
    func updateCountLabel(){
        let count = post!.likers.count
        
        countLabel.text = String(count)
    }
}