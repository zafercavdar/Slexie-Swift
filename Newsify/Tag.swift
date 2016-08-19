//
//  Tag.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import ObjectMapper

class Tag: Mappable{
    
    var confidence: Double?
    var tag: String?
    
    required init?(_ map: Map){
        
    }
    
    // Mappable
    func mapping(map: Map) {
        confidence <- map["confidence"]
        tag   <- map["tag"]
    }
}
