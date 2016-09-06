//
//  PostViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 05/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

class PostViewModel {

    var networkingController = FirebaseController()
    
    func pushNotification(notification: Notification){
        networkingController.pushNotification(notification){
        }
    }
    
    func removeNotification(notification: Notification){
        networkingController.removeNotification(notification){
            
        }
    }
    
    func likePhoto(id: String){
        networkingController.photoLiked(id) { (result) in
        }
    }
    
    func unlikePhoto(id: String){
        networkingController.photoUnliked(id) { (result) in
        }
    }
    
}
