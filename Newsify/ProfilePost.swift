//
//  ProfilePost.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

class ProfilePost: Post {

    override init(id: String, tags: [String], likers: [String], likeCount: Int, isAlreadyLiked: Bool) {
        super.init(id: id, tags: tags, likers: likers, likeCount: likeCount, isAlreadyLiked: isAlreadyLiked)
    }
}

