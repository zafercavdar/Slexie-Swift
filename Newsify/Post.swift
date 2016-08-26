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
    var likers: [String] = []
    var likeCount = 0
    var isAlreadyLiked = false
    
    init(id: String, tags: [String], likers: [String], likeCount: Int, isAlreadyLiked: Bool) {
        self.id = id
        self.tags = tags
        self.likers = likers
        self.likeCount = likeCount
        self.isAlreadyLiked = isAlreadyLiked
    }
    
    func setPhoto(photo: UIImage) {
        self.photo = photo
    }

}
