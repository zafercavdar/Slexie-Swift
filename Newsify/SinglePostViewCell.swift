//
//  PostViewCell.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class SinglePostViewCell: UITableViewCell {
    
    var tapRecognizer = AdvancedGestureRecognizer()
    var heartTapRecognizer = AdvancedGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}