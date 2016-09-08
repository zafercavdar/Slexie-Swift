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
        
        enum Change: Equatable{
            case none
            case notifications(CollectionChange)
            case loadingView(String)
            case removeView
            case postProduced(FeedPost)
        }
        
        mutating func reloadNotifications(notifs: [Notification]) -> Change{
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
                strongSelf.emit(strongSelf.state.reloadNotifications(notifications))
                
                for i in 0..<notifications.count {
                    let id = notifications[i].notificationTargetID
                    
                    strongSelf.networkingController.downloadPhoto(with: id, completion: { (image, error) in
                        if error == nil {
                            notifications[i].targetImage = UIImage.resizeImage(image!, newWidth: CGFloat(49))
                            strongSelf.emit(State.Change.removeView)
                            strongSelf.emit(strongSelf.state.reloadNotifications(notifications))
                            callback()
                        }
                    })
                }
            } else {
                strongSelf.emit(State.Change.removeView)
                let notification = Notification(ownerID: "", targetID: "", doneByUserID: "", doneByUsername: "", type: .Null)
                notification.targetImage = UIImage(named: "greyDefault")!
                strongSelf.emit(strongSelf.state.reloadNotifications([notification]))
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

func ==(lhs: NotificationsViewModel.State.Change, rhs: NotificationsViewModel.State.Change) -> Bool {
    
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.notifications(let update1), .notifications(let update2)):
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
    case (.loadingView(let text1) ,.loadingView(let text2)):
        return text1 == text2
    case (.removeView, .removeView):
        return true
    case (.postProduced(let post1), .postProduced(let post2)):
        return post1 == post2
    default:
        return false
    }
}

