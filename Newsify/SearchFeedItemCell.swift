//
//  SearchFeedItemCell.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class SearchFeedItemCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    var id: String = ""
    
    let tapRecognizer: AdvancedGestureRecognizer = AdvancedGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
