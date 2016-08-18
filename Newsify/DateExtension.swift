//
//  DateExtension.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

extension NSDate {
    
    var hour: Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: self).hour
    }
    
    var minute: Int {
        return NSCalendar.currentCalendar().components(.Minute, fromDate: self).minute
    }
    
    var seconds: Int {
        return NSCalendar.currentCalendar().components(.Second, fromDate: self).second
    }
    
    var year: Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: self).year
    }
    
    var month: Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: self).month
    }
    
    var day: Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: self).day
    }
    
    func uniqueTime() -> String {
        return "\(self.hour)\(self.minute)\(self.seconds)S\(self.day)\(self.month)\(self.year)"
    }
    
}
