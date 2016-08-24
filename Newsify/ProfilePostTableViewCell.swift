//
//  ProfilePostTableViewCell.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePostTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profilePostView: UIImageView!
    @IBOutlet weak var profilePostTags: UILabel!
    
    var id = ""
    
    let tapRecognizer: AdvancedGestureRecognizer = AdvancedGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
