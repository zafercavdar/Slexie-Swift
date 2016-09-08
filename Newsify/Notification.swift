//
//  Notification.swift
//  Slexie
//
//  Created by Zafer Cavdar on 29/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

enum NotificationType {
    case Liked
    case Commented
    case Null
    
    var actionString: String {
        switch self {
        case .Liked:
            return " has liked your photo."
        case .Commented:
            return " has commented on your photo."
        case .Null:
            return "There is no notification :("
        }
    }
}

class Notification: Equatable {
    var notificationOwnerID: String
    var notificationTargetID: String
    var notificationDoneByUserID: String
    var notificationDoneByUsername: String
    var notificationType: NotificationType
    var targetImage = UIImage()
    
    init(ownerID: String, targetID: String, doneByUserID: String, doneByUsername: String, type: NotificationType){
        notificationOwnerID = ownerID
        notificationTargetID = targetID
        notificationDoneByUserID = doneByUserID
        notificationDoneByUsername = doneByUsername
        notificationType = type
    }
}

func ==(lhs: Notification, rhs: Notification) -> Bool {
    return lhs.notificationDoneByUserID == rhs.notificationDoneByUserID && lhs.notificationTargetID == rhs.notificationTargetID && lhs.notificationType == rhs.notificationType && lhs.notificationOwnerID == rhs.notificationOwnerID
}
