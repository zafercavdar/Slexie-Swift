//
//  ContentIDResponse.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import ObjectMapper

class ContentIDResponse: Mappable {
    
    var status: String?
    var id: String?
    
    required init?(_ map: Map){
        
    }
    
    // Mappable
    func mapping(map: Map) {
        status <- map["status"]
        id     <- map["uploaded.0.id"]
    }
}