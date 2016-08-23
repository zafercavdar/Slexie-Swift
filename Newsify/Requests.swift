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

protocol RequestWithToken: Request {
    var authToken: String {get set}
}

protocol RequestWithKey: Request {
    var key: String {get set}
    var secret: String {get set}
}

struct IDRequest: RequestWithToken {

    var requestType: RequestType<NSData>
    var requestURL: String
    var authToken: String
}

struct TagsRequest: RequestWithKey{
    var requestType: RequestType<NSData>
    var requestURL: String
    var key: String
    var secret: String
}
