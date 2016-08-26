//
//  FeedPost.swift
//  Slexie
//
//  Created by Zafer Cavdar on 16/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

class FeedPost: Post {
    
    var username: String
    
    init(username: String, id: String, tags: [String], likers: [String], likeCount: Int, isAlreadyLiked: Bool) {
        self.username = username
        super.init(id: id, tags: tags, likers: likers, likeCount: likeCount, isAlreadyLiked: isAlreadyLiked)
    }
}