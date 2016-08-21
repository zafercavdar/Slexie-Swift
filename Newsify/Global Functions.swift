//
//  Global Functions.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

func indexOf(source: String, substring: String) -> Int? {
    let maxIndex = source.characters.count - substring.characters.count
    for index in 0...maxIndex {
        let rangeSubstring = source.startIndex.advancedBy(index)..<source.startIndex.advancedBy(index + substring.characters.count)
        if source.substringWithRange(rangeSubstring) == substring {
            return index
        }
    }
    return nil
}

func wait(seconds: NSTimeInterval)
{
    NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: seconds))
}

func += <K, V> (inout left: Dictionary <K,V> , right: Dictionary <K,V>) {
    for (k, v) in right {
        left[k] = v
    }
}