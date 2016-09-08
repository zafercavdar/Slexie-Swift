//
//  SinglePostViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 06/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

class SinglePostViewModel: PostViewModel{

    struct State{
        var post: FeedPost?
        
        enum Change: Equatable{
            case none
            case post(CollectionChange)
        }
        
        mutating func reloadPost(feedPost: FeedPost) -> Change{
            self.post = feedPost
            return Change.post(.reload)
        }
    }

    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
    
    func updatePost(post: FeedPost){
        self.emit(state.reloadPost(post))
    }
}

func ==(lhs: SinglePostViewModel.State.Change, rhs: SinglePostViewModel.State.Change) -> Bool {
    
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.post(let update1), .post(let update2)):
        switch (update1, update2) {
        case (.reload, .reload):
            return true
        default:
            return false
        }
    default:
        return false
    }
}



