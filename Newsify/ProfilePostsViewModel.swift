//
//  ProfilePostsViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class ProfilePostViewModel: HaveNetworkingController, TapExtendable{
    
    struct State{
        var profilePosts: [ProfilePost] = []
        
        enum Change{
            case none
            case posts(CollectionChange)
        }
        
        mutating func reloadPosts(profilePosts: [ProfilePost]) -> Change{
            self.profilePosts = profilePosts.reverse()
            return Change.posts(.reload)
        }
    }

    
    var networkingController = FirebaseController()
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?

        
    func fetchProfilePosts(completion callback: () -> Void) {
        
        networkingController.getProfilePosts { [weak self] (fetchedPosts) in
            
            guard let strongSelf = self else { return }
            
            if fetchedPosts.isEmpty {
                strongSelf.emit(strongSelf.state.reloadPosts(strongSelf.defaultPosts()))
                callback()
            } else {
                strongSelf.emit(strongSelf.state.reloadPosts(fetchedPosts))
                
                for post in strongSelf.state.profilePosts {
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
        }
    }
}

private extension ProfilePostViewModel {
    
    private func defaultPosts() -> [ProfilePost]{
        let defaultImage = UIImage(named: "greyDefault")
        let defaultTags = ["grey","grey", "grey"]
        
        let profileItem = ProfilePost(id: "no-id", tags: defaultTags)
        let profileItem2 = ProfilePost(id: "no-id", tags: defaultTags)
        
        profileItem.setPhoto(defaultImage!)
        profileItem2.setPhoto(defaultImage!)
        
        return [profileItem, profileItem2]
    }
    
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}
