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
