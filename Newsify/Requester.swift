//
//  Requester.swift
//  Slexie
//
//  Created by Zafer Cavdar on 22/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import ObjectMapper

protocol Requester {
    
    func makeRequest(request: Request, completion callback: (error: ErrorType?, response: Mappable?) -> Void)
    
}

