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
    case insertion(Int)
}

class FeedPostViewModel: PostViewModel {
    
    struct State{
        var feedPosts: [FeedPost] = []
        
        enum Change{
            case none
            case posts(CollectionChange)
            case loadingView(String)
            case removeView
        }
        
        mutating func reloadPosts(feedPosts: [FeedPost]) -> Change{
            self.feedPosts = feedPosts
            return Change.posts(.reload)
        }
        
        mutating func insertPost(feedPost: FeedPost) -> Change{
            self.feedPosts.append(feedPost)
            return Change.posts(.insertion(feedPosts.count - 1))
        }
        
        func showLoadingView(text: String) -> Change {
            return Change.loadingView(text)
        }
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
        
    func fetchFeedPosts(count count: Int, showView: Bool, completion callback: () -> Void) {
        
        if showView {
            self.emit(self.state.showLoadingView(localized("RefreshingInfo")))
        }
        
        networkingController.getAccountTags { (tags) in
            
            self.networkingController.getPhotosRelatedWith(tags, count: count, completion: { [weak self] (posts) in
                
                guard let strongSelf = self else { return }
                
                strongSelf.emit(State.Change.removeView)
                
                if posts.isEmpty {
                    strongSelf.emit(strongSelf.state.reloadPosts(strongSelf.defaultPosts()))
                    callback()
                } else {
                    //strongSelf.emit(strongSelf.state.reloadPosts(posts))
                    
                    for post in posts.reverse() {
                        if !strongSelf.checkContains(post){
                            strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                                if error == nil {
                                    post.setPhoto(image!)
                                    print("Adding new photo")
                                    strongSelf.emit(strongSelf.state.insertPost(post))
                                    callback()
                                }
                            })
                        }
                        
                    }
                }
            })
        }
    }
    
    private func checkContains(feedPost: FeedPost) -> Bool{
        for statePost in state.feedPosts {
            if statePost.id == feedPost.id {
                return true
            }
        }
        
        return false
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