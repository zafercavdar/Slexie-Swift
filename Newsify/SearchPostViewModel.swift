//
//  SearchPostViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 23/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class SearchPostViewModel: NotificationSender {
    
    struct State{
        var searchPosts: [FeedPost] = []
        
        enum Change{
            case none
            case posts(CollectionChange)
        }
        
        mutating func reloadPosts(searchPosts: [FeedPost]) -> Change{
            self.searchPosts = searchPosts.reverse()
            return Change.posts(.reload)
        }
    }
    
    var networkingController = FirebaseController()
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    
    func fetchSearchPosts(searchTag: String, completion callback: () -> Void) {
        
        networkingController.getPhotosRelatedWith([searchTag], count: 100, completion: { [weak self] (posts) in
                
                guard let strongSelf = self else { return }
                
                if posts.isEmpty {
                    strongSelf.emit(strongSelf.state.reloadPosts([]))
                    callback()
                } else {
                    strongSelf.emit(strongSelf.state.reloadPosts(posts))
                    
                    for post in strongSelf.state.searchPosts {
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
    
    func likePhoto(id: String){
        networkingController.photoLiked(id) { (result) in
            
        }
    }
    
    func cleanSearchPosts(){
        self.emit(self.state.reloadPosts([]))
    }
    
}

private extension SearchPostViewModel {
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
    
}
