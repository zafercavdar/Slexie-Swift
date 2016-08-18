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
        
        var fetchedPosts: [FeedPost] = []
        
        networkingController.getAccountTags { (tags) in
            print("searching for \(tags)")
            self.networkingController.getPhotosRelatedWith(tags, completion: { (posts) in
                
                for post in posts {
                    print("fetched \(post.username)")
                    fetchedPosts.append(post)
                }
                
                if fetchedPosts.isEmpty {
                    print("fetchedPosts are empty")
                    self.feedPosts = self.defaultPosts()
                } else {
                    print("fetchedPosts are NOT empty")
                    self.feedPosts = fetchedPosts
                    
                    for post in self.feedPosts {
                        self.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
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
    
    func defaultPosts() -> [FeedPost]{
        let defaultImage = UIImage(named: "example1")
        let defaultUsername = "jane"
        let defaultTags = ["food","spoon", "wood"]
        
        let defaultImage2 = UIImage(named: "example2")
        let defaultUsername2 = "michael"
        let defaultTags2 = ["friends","fun", "together"]
        
        let feedItem = FeedPost(username: defaultUsername, id: "no-id", tags: defaultTags)
        let feedItem2 = FeedPost(username: defaultUsername2, id: "no-id", tags: defaultTags2)
        
        feedItem.setPhoto(defaultImage!)
        feedItem2.setPhoto(defaultImage2!)
        
        return [feedItem,feedItem2]
    }
}

func += <K, V> (inout left: Dictionary <K,V> , right: Dictionary <K,V>) {
    for (k, v) in right {
        left[k] = v
    }
}
