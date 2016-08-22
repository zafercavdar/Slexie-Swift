//
//  Request.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

enum RequestType<Value: NSData> {
    case GET()
    case POST(Value)
}

protocol Request {
    var requestType: RequestType<NSData> {get set}
    var requestURL: String {get set}
}

protocol ContentIDRequest: Request {
    var authToken: String {get set}
}

protocol TagRequest: Request {
    var username: String {get set}
    var password: String {get set}
}

struct IDRequest: ContentIDRequest {

    var requestType: RequestType<NSData>
    var requestURL: String
    var authToken: String
}

struct TagsRequest: TagRequest{
    var requestType: RequestType<NSData>
    var requestURL: String
    var username: String
    var password: String
}
