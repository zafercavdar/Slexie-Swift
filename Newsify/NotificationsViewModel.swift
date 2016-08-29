//
//  NotificationsViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 29/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

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
        networkingController.fethNotifications { (notifications) in
            
            if !notifications.isEmpty {
                self.emit(self.state.reloadPosts(notifications))
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