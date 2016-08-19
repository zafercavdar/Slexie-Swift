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
        
        networkingController.getProfilePosts { [weak self] (fetchedPosts) in
            
            guard let strongSelf = self else { return }
            
            if fetchedPosts.isEmpty {
                strongSelf.profilePosts = strongSelf.defaultPosts()
            } else {
                strongSelf.profilePosts = fetchedPosts.reverse()
                
                for post in strongSelf.profilePosts {
                    strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                        guard error != nil else {
                            post.setPhoto(image!)
                            callback()
                            return
                        }
                    })
                }
            }
        }
    }
}

extension ProfilePostViewModel {
    
    private func defaultPosts() -> [ProfilePost]{
        let defaultImage = UIImage(named: "greyDefault")
        let defaultTags = ["grey","grey", "grey"]
        
        let profileItem = ProfilePost(id: "no-id", tags: defaultTags)
        let profileItem2 = ProfilePost(id: "no-id", tags: defaultTags)
        
        profileItem.setPhoto(defaultImage!)
        profileItem2.setPhoto(defaultImage!)
        
        return [profileItem, profileItem2]
    }
}
