//
//  FeedPost.swift
//  Slexie
//
//  Created by Zafer Cavdar on 16/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

class FeedPost: Post {
    
    var username: String
    
    init(username: String, id: String, tags: [String]) {
        self.username = username
        super.init(id: id, tags: tags)
    }
}