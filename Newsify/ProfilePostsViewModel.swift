//
//  ProfilePostsViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePostViewModel: PostViewModel {
    
    struct State{
        var profilePosts: [FeedPost] = []
        
        enum Change{
            case none
            case posts(CollectionChange)
            case loadingView(String)
            case removeView
        }
        
        mutating func reloadPosts(profilePosts: [FeedPost]) -> Change{
            self.profilePosts = profilePosts.reverse()
            return Change.posts(.reload)
        }
        
        mutating func deletePost(index: Int) -> Change {
            self.profilePosts.removeAtIndex(index)
            return Change.posts(.deletion(index))
        }
        
        func showView(text: String) -> Change {
            return Change.loadingView(text)
        }
    }

    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?

        
    func fetchProfilePosts(showView: Bool, completion callback: () -> Void) {
        
        if showView {
            self.emit(state.showView(localized("RefreshingInfo")))
        }
        
        networkingController.getProfilePosts { [weak self] (fetchedPosts) in
            
            guard let strongSelf = self else { return }
            
            if showView{
                strongSelf.emit(State.Change.removeView)
            }
            
            if fetchedPosts.isEmpty {
                strongSelf.emit(strongSelf.state.reloadPosts(strongSelf.defaultPosts()))
                callback()
            } else {
                strongSelf.emit(strongSelf.state.reloadPosts(fetchedPosts))
                
                for post in strongSelf.state.profilePosts {
                    strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                        
                        if error == nil {
                            post.setPhoto(image!)
                            strongSelf.emit(State.Change.posts(.reload))
                            callback()
                        }
                    })
                }
            }
        }
    }
    
    func deletePost(id: String, index: Int){
        networkingController.deletePost(with: id)
        self.emit(state.deletePost(index))
    }
}

private extension ProfilePostViewModel {
    
    private func defaultPosts() -> [FeedPost]{
        
        let defaultImage = UIImage(named: "example1")
        let defaultUsername = "zctr"
        let defaultTags = ["food","spoon", "wood"]
        
        let defaultImage2 = UIImage(named: "example2")
        let defaultUsername2 = "zctr"
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
