//
//  Request.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

struct Request {
    
    var requestType: RequestType<NSData>
    var requestURL: String
    var username: String
    var password: String
    var authToken: String
}

enum RequestType<Value: NSData> {
    case GET()
    case POST(Value)
}