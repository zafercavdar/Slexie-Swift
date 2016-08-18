//
//  ProfilePostsViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class ProfilePostViewModel {
    
    var profilePosts: [ProfilePost] = []
    let networkingController = FBNetworkingController()
    
    func fetchProfilePosts(completion callback: () -> Void) {
        
        var fetchedPosts: [FeedPost] = []
    
        if fetchedPosts.isEmpty{
            profilePosts = defaultPosts()
        }
        
        callback()
    }
}

extension ProfilePostViewModel {
    
    func defaultPosts() -> [ProfilePost]{
        let defaultImage = UIImage(named: "greyDefault")
        let defaultTags = ["grey","grey", "grey"]
        
        let profileItem = ProfilePost(id: "no-id", tags: defaultTags)
        let profileItem2 = ProfilePost(id: "no-id", tags: defaultTags)
        
        profileItem.setPhoto(defaultImage!)
        profileItem2.setPhoto(defaultImage!)
        
        return [profileItem, profileItem2]
    }
}
