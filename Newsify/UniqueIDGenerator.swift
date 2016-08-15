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
}

extension NSDate {
    func hour() -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: self).hour
    }
    
    func minute() -> Int {
        return NSCalendar.currentCalendar().components(.Minute, fromDate: self).minute
    }
    
    func seconds() -> Int {
        return NSCalendar.currentCalendar().components(.Second, fromDate: self).second
    }
    
    func year() -> Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: self).year
    }
    
    func month() -> Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: self).month
    }
    
    func day() -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: self).day
    }
    
    func uniqueTime() -> String {
        return "\(self.hour())\(self.minute())\(self.seconds())S\(self.day())\(self.month())\(self.year())"
    }
    
}
