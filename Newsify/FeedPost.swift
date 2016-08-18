//
//  FeedPost.swift
//  Slexie
//
//  Created by Zafer Cavdar on 16/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class FeedPost {
    
    var username: String
    var id: String
    var tags: [String] = []
    var photo = UIImage(named: "greyDefault")
    
    init(username: String, id: String, tags: [String]) {
        self.username = username
        self.id = id
        self.tags = tags
    }
    
    func setPhoto(photo: UIImage) {
        self.photo = photo
    }
}