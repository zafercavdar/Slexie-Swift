//
//  TagResponse.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import ObjectMapper

class TagResponse: Mappable{

    var tagging_id: String?
    var imageURL: String?
    var tags: [Tag]?
    
    required init?(_ map: Map){
        
    }
    
    // Mappable
    func mapping(map: Map) {
        tagging_id <- map["results.0.tagging_id"]
        imageURL   <- map["results.0.image"]
        tags       <- map["results.0.tags"]
    }
}

class Tag: Mappable{
    
    var confidence: Double?
    var tag: String?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        confidence <- map["confidence"]
        tag   <- map["tag"]
    }
}
