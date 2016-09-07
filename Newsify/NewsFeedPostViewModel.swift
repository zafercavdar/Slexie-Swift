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
    case deletion(Int)
}

class NewsFeedPostViewModel: PostViewModel {
    
    struct State{
        var feedPosts: [FeedPost] = []
        
        enum Change{
            case none
            case posts(CollectionChange)
            case loadingView(String)
            case removeView
            case emptyFeed
        }
        
        mutating func reloadPosts(feedPosts: [FeedPost]) -> Change{
            self.feedPosts = feedPosts
            return Change.posts(.reload)
        }
        
        mutating func insertPost(feedPost: FeedPost) -> Change{
            self.feedPosts.append(feedPost)
            return Change.posts(.insertion(feedPosts.count - 1))
        }
        
        mutating func deletePost(index: Int) -> Change {
            self.feedPosts.removeAtIndex(index)
            return Change.posts(.deletion(index))
        }
        
        mutating func clearPosts() -> Change{
            self.feedPosts = []
            return Change.posts(.reload)
        }
        
        func showLoadingView(text: String) -> Change {
            return Change.loadingView(text)
        }
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    
    func reloadFeedPosts(count count: Int, completion callback: () -> Void) {
        print("reloading: " + String(count))
        networkingController.getAccountTags { (tags) in
            
            self.networkingController.getPhotosRelatedWith(tags, count: count, completion: { [weak self] (posts) in
                
                guard let strongSelf = self else { return }
                
                if posts.isEmpty {
                    strongSelf.emit(State.Change.emptyFeed)
                    callback()
                } else {
 
                    let reversed = posts.reverse() as [FeedPost]
                    
                    strongSelf.emit(strongSelf.state.reloadPosts(reversed))
                    
                    for post in reversed {
                            strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                                if error == nil {
                                    post.setPhoto(image!)
                                    print(post.id)
                                    strongSelf.emit(strongSelf.state.reloadPosts(reversed))
                                    callback()
                                }
                            })
                    }
                }
            })
        }
    }

    
    func fetchFeedPosts(count count: Int, showView: Bool, completion callback: () -> Void) {
        
        print("fetching: " + String(count))

        
        if showView {
            self.emit(self.state.showLoadingView(localized("RefreshingInfo")))
        }
        
        networkingController.getAccountTags { (tags) in
            
            self.networkingController.getPhotosRelatedWith(tags, count: count, completion: { [weak self] (posts) in
                
                guard let strongSelf = self else { return }
                
                strongSelf.emit(State.Change.removeView)
                
                if posts.isEmpty {
                    strongSelf.emit(State.Change.emptyFeed)
                    //strongSelf.emit(strongSelf.state.reloadPosts(strongSelf.defaultPosts()))
                    callback()
                } else {
                    //strongSelf.emit(strongSelf.state.reloadPosts(posts.reverse()))
                    
                    for post in posts.reverse() {
                        if !strongSelf.checkContains(post){
                            strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                                if error == nil {
                                    post.setPhoto(image!)
                                    print(post.id)
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
    
    func reportPost(id: String){
        networkingController.reportPost(id)
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

private extension NewsFeedPostViewModel {
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
    
}