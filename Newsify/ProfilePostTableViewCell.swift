//
//  ProfilePostTableViewCell.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePostTableViewCell: UITableViewCell {
    
    var tapRecognizer: AdvancedGestureRecognizer = AdvancedGestureRecognizer()
    var heartTapRecognizer = AdvancedGestureRecognizer()
    
    var indexPath = NSIndexPath()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
