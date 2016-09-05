//
//  PostView.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class PostView {

    var headerView = UIView() // username
    var cellView = UIView() // image and tags
    private var heartTapView = UIImageView()
    var footerView = UIView() // like button + count
    private var likedView = UIImageView()
    private var countLabel = UILabel()
    
    private var post: FeedPostPresentation? = nil
    
    init(post: FeedPostPresentation){
    
        self.post = post
        
        createHeaderView()
        createCellView()
        createFooterView()
        
    }
    
    private func createHeaderView(){
        let username = post?.ownerName
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
        
    }
    
    private func createCellView(){
        let image = post?.image
        let tags = post?.tagList
        let width = UIScreen.mainScreen().bounds.size.width

        cellView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width + 30))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        imageView.image = image
        imageView.contentMode = .ScaleAspectFit
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
        tagsLabel.text = tags
        tagsLabel.textAlignment = .Center
        tagsLabel.font = UIFont.boldSystemFontOfSize(10.00)
        tagsLabel.center.x = cellView.center.x
        cellView.addSubview(tagsLabel)
        
    }
    
    private func createFooterView(){
        let width = Double(UIScreen.mainScreen().bounds.size.width)
        
        let offSet = 0.0
        let gap = 0.0
        let imageWidth = 44.0
        let labelWidth = 10.0

        footerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 54))
        footerView.backgroundColor = UIColor.whiteColor()
        likedView = UIImageView(frame: CGRect(x: (width - imageWidth - gap - labelWidth)/2, y: offSet, width: imageWidth, height: imageWidth))
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
        let liked = post!.liked
        var image = UIImage()
        
        image = liked ? UIImage(named: "Filled Heart")! : UIImage(named: "Empty Heart")!
        likedView.image = image
    }
    
    func updateCountLabel(){
        let count = post!.likeCount
        
        countLabel.text = String(count)
    }
    
}
