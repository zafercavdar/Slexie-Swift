//
//  TagRequest.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

class TagRequest: Request {
    
    let contentType = "application/json"

    func request(requestType: RequestType<NSData>, requestURL: String, username: String, password: String, authToken: String, completion callback: (error: ErrorType?, response: Mappable?) -> Void){
    
        switch requestType {
        case .GET():
            Alamofire.request(.GET, requestURL).authenticate(user: username, password: password)
                .validate(contentType: [contentType]).responseObject { (response: Response<TagResponse, NSError>) in
                    
                    switch response.result {
                    case .Success:
                        if let tagResponse = response.result.value {
                            callback(error: nil, response: tagResponse)
                        } else {
                            callback(error: nil, response: nil)
                        }
                    case .Failure(let error):
                        callback(error: error, response: nil)
                    }
            }
        case .POST(_):
            print("TagRequest is a type of GET request.")
        }
    }
    
}
