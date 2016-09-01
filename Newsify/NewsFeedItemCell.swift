//
//  NewsFeedItemCell.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit


class AdvancedGestureRecognizer: UITapGestureRecognizer {
    var tappedCell = UITableViewCell()
}


class NewsFeedItemCell: UITableViewCell, Likeable{

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var heart: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    
    var postPresentation = FeedPostsPresentation()
    
    var likedView: UIImageView!
    var tapRecognizer = AdvancedGestureRecognizer()
    var heartTapRecognizer = AdvancedGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likedView = generateLikedView(photoView)
        photoView.addSubview(likedView)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
