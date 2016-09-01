//
//  TapExtendable.swift
//  Slexie
//
//  Created by Zafer Cavdar on 25/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

protocol NotificationSender {
    
}

extension NotificationSender{
    
    func pushNotification(notification: Notification){
        let networkingController = FirebaseController()
        networkingController.pushNotification(notification){
            
        }
    }
    
    func removeNotification(notification: Notification){
        let networkingController = FirebaseController()
        networkingController.removeNotification(notification){
            
        }
    }
}

protocol LikerUnliker {

}

extension LikerUnliker {
    
    func likePhoto(id: String){
        let networkingController = FirebaseController()
        networkingController.photoLiked(id) { (result) in
            
        }
    }
    
    func unlikePhoto(id: String){
        let networkingController = FirebaseController()
        networkingController.photoUnliked(id) { (result) in
            
        }
    }


}