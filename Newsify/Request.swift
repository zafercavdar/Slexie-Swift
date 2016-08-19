//
//  Request.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import ObjectMapper

protocol Request {

    func request(requestType: RequestType<NSData>, requestURL: String, username: String, password: String, authToken: String, completion callback: (error: ErrorType?, response: Mappable?) -> Void)
}

enum RequestType<Value: NSData> {
    case GET()
    case POST(Value)
}