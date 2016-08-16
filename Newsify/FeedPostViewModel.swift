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
        
    func fetchFeedPosts() {
        
        var fetchedPosts: [FeedPost] = []
        var uniqueDic: [String: FeedPost] = [:]
        
        networkingController.getAccountTags { (tags) in
            print("searching for \(tags)")
            self.networkingController.getPhotosRelatedWith(tags, completion: { (resultDic) in
                uniqueDic += resultDic
                
                for post in uniqueDic.values {
                    print("fetched \(post.username)")
                    fetchedPosts.append(post)
                }
                
                if fetchedPosts.isEmpty {
                    print("fetchedPosts are empty")
                    self.feedPosts = self.defaultPosts()
                } else {
                    print("fetchedPosts are NOT empty")
                    self.feedPosts = fetchedPosts
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
        let feedItem = FeedPost(username: defaultUsername, photo: defaultImage!, tags: defaultTags)
        let feedItem2 = FeedPost(username: defaultUsername2, photo: defaultImage2!, tags: defaultTags2)
        
        return [feedItem,feedItem2]
    }
}

func += <K, V> (inout left: Dictionary <K,V> , right: Dictionary <K,V>) {
    for (k, v) in right {
        left[k] = v
    }
}
