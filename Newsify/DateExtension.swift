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
        let month = self.month
        let day = self.day
        let hour = self.hour
        let minute = self.minute
        let second = self.seconds
        var sMonth = "\(month)"
        var sDay = "\(day)"
        var sHour = "\(hour)"
        var sMinute = "\(minute)"
        var sSeconds = "\(second)"
        
        if month < 10 {
            sMonth = "0\(month)"
        }
        
        if day < 10 {
            sDay = "0\(day)"
        }
        
        if hour < 10 {
            sHour = "0\(hour)"
        }
        
        if minute < 10 {
            sMinute = "0\(minute)"
        }
        
        if second < 10 {
            sSeconds = "0\(second)"
        }
        
        return "\(self.year)\(sMonth)\(sDay)S\(sHour)\(sMinute)\(sSeconds)"
    }
    
}
