//
//  Post.swift
//  Slexie
//
//  Created by Zafer Cavdar on 22/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class Post {

    var id: String
    var tags: [String] = []
    var photo = UIImage(named: "greyDefault")
    
    init(id: String, tags: [String]) {
        self.id = id
        self.tags = tags
    }
    
    func setPhoto(photo: UIImage) {
        self.photo = photo
    }

    
}
