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
            case loadingView(String)
            case removeView
            case postProduced(FeedPost)
        }
        
        mutating func reloadPosts(notifs: [Notification]) -> Change{
            self.notifs = notifs.reverse()
            return Change.notifications(.reload)
        }
        
        func callLoadingView(text: String) -> Change{
            return Change.loadingView(text)
        }
    }
    
    var networkingController = FirebaseController()
    private(set) var state = State()
    var stateChangeHandler: ((State.Change) -> Void)?

    func fetchNotifications(showView: Bool, completion callback: () -> Void){
        
        if showView {
            self.emit(state.callLoadingView(localized("RefreshingInfo")))
        }
        
        networkingController.fetchNotifications { [weak self] (notifications) in
            
            guard let strongSelf = self else { return }
            
            if !notifications.isEmpty {
                strongSelf.emit(strongSelf.state.reloadPosts(notifications))
                
                for i in 0..<notifications.count {
                    let id = notifications[i].notificationTargetID
                    
                    strongSelf.networkingController.downloadPhoto(with: id, completion: { (image, error) in
                        if error == nil {
                            notifications[i].targetImage = UIImage.resizeImage(image!, newWidth: CGFloat(49))
                            strongSelf.emit(State.Change.removeView)
                            strongSelf.emit(strongSelf.state.reloadPosts(notifications))
                            callback()
                        }
                    })
                }
            } else {
                strongSelf.emit(State.Change.removeView)
                let notification = Notification(ownerID: "", targetID: "", doneByUserID: "", doneByUsername: "", type: .Null)
                notification.targetImage = UIImage(named: "greyDefault")!
                strongSelf.emit(strongSelf.state.reloadPosts([notification]))
            }
            callback()
        }
    }
    
    func startListeningNotifications(){
        
    }
    
    func detailedInfoAboutPost(postID: String){
        networkingController.getPost(with: postID) { (singlePost) in
            
            self.networkingController.downloadPhoto(with: postID, completion: { (image, error) in
                if error == nil {
                    singlePost.photo = image!
                }
                
                self.emit(State.Change.postProduced(singlePost))

            })
            
        }
    }
    
}

private extension NotificationsViewModel {
    private func emit(change: State.Change){
        stateChangeHandler?(change)
    }
}