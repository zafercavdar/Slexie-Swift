//
//  ProfilePostTableViewCell.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePostTableViewCell: UITableViewCell, Likeable {

    
    @IBOutlet weak var profilePostView: UIImageView!
    @IBOutlet weak var profilePostTags: UILabel!
    @IBOutlet weak var heart: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    
    var postPresentation = ProfilePostsPresentation()

    
    var tapRecognizer: AdvancedGestureRecognizer = AdvancedGestureRecognizer()
    var likedView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likedView = generateLikedView(profilePostView)
        profilePostView.addSubview(likedView)
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
