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
}