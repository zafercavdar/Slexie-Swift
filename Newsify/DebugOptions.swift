//
//  DebugOptions.swift
//  Slexie
//
//  Created by Zafer Cavdar on 18/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG
        
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
        
    #endif
}