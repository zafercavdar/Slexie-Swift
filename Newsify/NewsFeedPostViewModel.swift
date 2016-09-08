//
//  FeedItemViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 16/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class NewsFeedPostViewModel: PostViewModel {
    
    struct State{
        var feedPosts: [FeedPost] = []
        var loadingState = LoadingState()
        
        enum Change: Equatable{
            case none
            case posts(CollectionChange)
            case loading(LoadingState)
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
        
        mutating func addActivity() -> Change {
            
            loadingState.addActivity()
            return Change.loading(loadingState)
        }
        
        mutating func removeActivity() -> Change {
            
            loadingState.removeActivity()
            return .loading(loadingState)
        }
        
        mutating func clearPosts() -> Change{
            self.feedPosts = []
            return Change.posts(.reload)
        }
        
    }
    
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    
    func reloadFeedPosts(count count: Int, completion callback: () -> Void) {
        //print("reloading: " + String(count))
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
        
        if showView {
            self.emit(self.state.addActivity())
        }
        
        networkingController.getAccountTags { (tags) in
            
            self.networkingController.getPhotosRelatedWith(tags, count: count, completion: { [weak self] (posts) in
                
                guard let strongSelf = self else { return }
                
                if showView{
                    strongSelf.emit(strongSelf.state.removeActivity())
                }
                
                if posts.isEmpty {
                    strongSelf.emit(State.Change.emptyFeed)
                    callback()
                } else {
                    for post in posts.reverse() {
                        if !strongSelf.checkContains(post){
                            strongSelf.networkingController.downloadPhoto(with: post.id, completion: { (image, error) in
                                if error == nil {
                                    post.setPhoto(image!)
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

// MARK: Equatable

func ==(lhs: NewsFeedPostViewModel.State.Change, rhs: NewsFeedPostViewModel.State.Change) -> Bool {
    
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.posts(let update1), .posts(let update2)):
        switch (update1, update2) {
        case (.reload, .reload):
            return true
        case (.insertion(let index1), .insertion(let index2)):
            return index1 == index2
        case (.deletion(let index1), .deletion(let index2)):
            return index1 == index2
        default:
            return false
        }
    case (.loading(let loadingState1), .loading(let loadingState2)):
        return loadingState1.activityCount == loadingState2.activityCount
    case (.emptyFeed, .emptyFeed):
        return true
    default:
        return false
    }
}
