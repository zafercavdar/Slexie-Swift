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
        
        enum Change{
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

    
}