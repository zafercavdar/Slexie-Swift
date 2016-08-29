//
//  FeedItemViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 16/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit


enum CollectionChange {
    case reload
}


class FeedPostViewModel: NotificationSender {
    
    struct State{
        var feedPosts: [FeedPost] = []
        
        enum Change{
            case none
            case posts(CollectionChange)
        }
        
        mutating func reloadPosts(feedPosts: [FeedPost]) -> Change{
            self.feedPosts = feedPosts.reverse()
            return Change.posts(.reload)
        }
    }
    
    var networkingController = FirebaseController()
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
        
    func fetchFeedPosts(completion callback: () -> Void) {
        
        networkingController.getAccountTags { (tags) in
            
            self.networkingController.getPhotosRelatedWith(tags, completion: { [weak self] (posts) in
                                
                guard let strongSelf = self else { return }
                
                if posts.isEmpty {
                    strongSelf.emit(strongSelf.state.reloadPosts(strongSelf.defaultPosts()))
                    callback()
                } else {
                    strongSelf.emit(strongSelf.state.reloadPosts(posts))
                    
                    for post in strongSelf.state.feedPosts {
                        strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                            guard error != nil else {
                                post.setPhoto(image!)
                                strongSelf.emit(State.Change.posts(.reload))
                                callback()
                                return
                            }
                        })
                    }
                }
            })
        }
    }
    
    func likePhoto(id: String){
        networkingController.photoLiked(id) { (result) in
            
        }
    }
}

private extension FeedPostViewModel {
    
    private func defaultPosts() -> [FeedPost]{
        let defaultImage = UIImage(named: "example1")
        let defaultUsername = "default-id"
        let defaultTags = ["food","spoon", "wood"]
        
        let defaultImage2 = UIImage(named: "example2")
        let defaultUsername2 = "default-id-2"
        let defaultTags2 = ["friends","fun", "together"]
        
        let feedItem = FeedPost(ownerUsername: defaultUsername, ownerID: "665d5s565d56", id: "no-id", tags: defaultTags, likers: [], likeCount: 11, isAlreadyLiked: false)
        let feedItem2 = FeedPost(ownerUsername: defaultUsername2, ownerID: "79009fd9fdg", id: "no-id", tags: defaultTags2, likers: [], likeCount: 13, isAlreadyLiked: true)
        
        feedItem.setPhoto(defaultImage!)
        feedItem2.setPhoto(defaultImage2!)
        
        return [feedItem,feedItem2]
    }
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
    
}