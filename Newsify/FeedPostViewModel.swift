//
//  FeedItemViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 16/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

class FeedPostViewModel {

    var feedPosts: [FeedPost] = []
    let networkingController = FBNetworkingController()
        
    func fetchFeedPosts(completion callback: () -> Void) {
        
        networkingController.getAccountTags { (tags) in
            self.networkingController.getPhotosRelatedWith(tags, completion: { [weak self] (posts) in
                
                guard let strongSelf = self else { return }
                
                if posts.isEmpty {
                    print("Fetched Posts are empty")
                    strongSelf.feedPosts = strongSelf.defaultPosts()
                    callback()
                } else {
                    print("Fetched Posts are NOT empty")
                    strongSelf.feedPosts = posts.reverse()
                    
                    
                    for post in strongSelf.feedPosts {
                        strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                            guard error != nil else {
                                post.setPhoto(image!)
                                callback()
                                return
                            }
                        })
                    }
                }
            })
        }
    }
}

extension FeedPostViewModel {
    
    private func defaultPosts() -> [FeedPost]{
        let defaultImage = UIImage(named: "example1")
        let defaultUsername = "default-id"
        let defaultTags = ["food","spoon", "wood"]
        
        let defaultImage2 = UIImage(named: "example2")
        let defaultUsername2 = "default-id-2"
        let defaultTags2 = ["friends","fun", "together"]
        
        let feedItem = FeedPost(username: defaultUsername, id: "no-id", tags: defaultTags)
        let feedItem2 = FeedPost(username: defaultUsername2, id: "no-id", tags: defaultTags2)
        
        feedItem.setPhoto(defaultImage!)
        feedItem2.setPhoto(defaultImage2!)
        
        return [feedItem,feedItem2]
    }
}