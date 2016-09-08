//
//  Structs.swift
//  Slexie
//
//  Created by Zafer Cavdar on 08/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

enum CollectionChange {
    
    case insertion(Int)
    case deletion(Int)
    case reload
}

struct LoadingState {
    
    private(set) var activityCount: UInt = 0
    private(set) var needsUpdate = false
    
    var isActive: Bool {
        return activityCount > 0
    }
    
    mutating func addActivity() {
        
        needsUpdate = (activityCount == 0)
        activityCount += 1
    }
    
    mutating func removeActivity() {
        
        guard activityCount > 0 else {
            return
        }
        activityCount -= 1
        needsUpdate = (activityCount == 0)
    }
}
