//
//  Notification.swift
//  Slexie
//
//  Created by Zafer Cavdar on 29/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

enum NotificationType {
    case Liked
    case Commented
    
    var actionString: String {
        switch self {
        case .Liked:
            return " has liked your photo."
        case .Commented:
            return " has commented on your photo."
        }
    }
}

struct Notification {
    var notificationOwnerID: String
    var notificationTargetID: String
    var notificationDoneByUserID: String
    var notificationDoneByUsername: String
    var notificationType: NotificationType
}