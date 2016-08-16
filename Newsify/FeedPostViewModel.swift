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
            for tag in tags {
                self.networkingController.getPhotosRelatedWith(tag, completion: { (resultDic) in
                    print("searching for \(tag)")
                    uniqueDic += resultDic
                })
            }
            
            for post in uniqueDic.values {
                fetchedPosts.append(post)
            }
            
            if fetchedPosts.isEmpty {
                self.feedPosts = self.defaultPosts()
            } else {
                self.feedPosts = fetchedPosts
            }
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
