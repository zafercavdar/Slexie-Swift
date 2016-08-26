//
//  SearchFeedItemCell.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class SearchFeedItemCell: UITableViewCell, Likeable{
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var heart: UIImageView!
    @IBOutlet weak var likeCount: UILabel!
    
    var id: String = ""
    
    var tapRecognizer: AdvancedGestureRecognizer = AdvancedGestureRecognizer()
    var likedView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likedView = generateLikedView(photoView)
        photoView.addSubview(likedView)

        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
