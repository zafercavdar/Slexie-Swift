//
//  NotificationsViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 29/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import UIKit

class NotificationsViewModel {
    
    struct State{
        var notifs: [Notification] = []
        
        enum Change{
            case none
            case notifications(CollectionChange)
        }
        
        mutating func reloadPosts(notifs: [Notification]) -> Change{
            self.notifs = notifs.reverse()
            return Change.notifications(.reload)
        }
    }
    
    var networkingController = FirebaseController()
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?

    func fetchNotifications(completion callback: () -> Void){
        networkingController.fethNotifications { [weak self] (notifications) in
            
            guard let strongSelf = self else { return }
            
            if !notifications.isEmpty {
                strongSelf.emit(strongSelf.state.reloadPosts(notifications))
                
                for i in 0..<notifications.count {
                    let id = notifications[i].notificationTargetID
                    
                    strongSelf.networkingController.downloadPhoto(with: id, completion: { (image, error) in
                        if error == nil {
                            notifications[i].targetImage = UIImage.resizeImage(image!, newWidth: CGFloat(49))
                            strongSelf.emit(strongSelf.state.reloadPosts(notifications))
                            callback()
                        }
                    })
                }
                
            }
            callback()
        }
    }
    
}

private extension NotificationsViewModel {
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}