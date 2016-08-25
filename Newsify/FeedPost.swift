//
//  FeedPost.swift
//  Slexie
//
//  Created by Zafer Cavdar on 16/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

class FeedPost: Post {
    
    var username: String
    
    init(username: String, id: String, tags: [String], likeCount: Int) {
        self.username = username
        super.init(id: id, tags: tags, likeCount: likeCount)
    }
}