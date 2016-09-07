//
//  UniqueIDGenerator.swift
//  Slexie
//
//  Created by Zafer Cavdar on 12/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

class UniqueIDGenerator {

    func generatePhotoID(userID: String) -> String{
        let date = NSDate()
        return "\(date.uniqueTime())UU\(userID)"
    }
    
    func generateNotificationID(notification: Notification) -> String{
    
        let time = NSDate().uniqueTime()
        var type: String
        
        switch notification.notificationType {
        case .Liked:
            type = "Like"
        case .Commented:
            type = "Comment"
        default:
            type = "Unknown"
        }
        
        let actionTrigger = notification.notificationDoneByUserID
        
        return "\(time)TT\(type)UU\(actionTrigger)"
    }
    
    func generateReportID(id: String) -> String{
        let time = NSDate().uniqueTime()
        return "\(time)RRR\(id)"
    }
}
