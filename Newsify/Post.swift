//
//  Post.swift
//  Slexie
//
//  Created by Zafer Cavdar on 22/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class Post {

    var id: String
    var tags: [String] = []
    var photo = UIImage(named: "greyDefault")
    var likeCount = 0
    
    init(id: String, tags: [String], likeCount: Int) {
        self.id = id
        self.tags = tags
        self.likeCount = likeCount
    }
    
    func setPhoto(photo: UIImage) {
        self.photo = photo
    }

}
