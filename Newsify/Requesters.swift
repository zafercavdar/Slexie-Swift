//
//  Requester.swift
//  Slexie
//
//  Created by Zafer Cavdar on 22/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import ObjectMapper
import AlamofireObjectMapper
import Alamofire

protocol Requester {
    
    func makeRequest(request: Request, completion callback: (error: ErrorType?, response: Mappable?) -> Void)
}

class ContentIDRequester: Requester {
    
    func makeRequest(request: Request, completion callback: (error: ErrorType?, response: Mappable?) -> Void) {
        
        guard let request = request as? ContentIDRequest else {
            return
        }
        
        switch request.requestType {
        case .GET():
            print("ContentIDRequest is a type of POST request.")
        case .POST(let imageData):
            Alamofire.upload(.POST, request.requestURL,headers: ["Authorization": request.authToken],
                             multipartFormData: { multipartFormData in
                                
                                multipartFormData.appendBodyPart(data: imageData, name: "file", fileName: "myImage.png", mimeType: "image/png")
                                
                },
                             encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .Success(let upload, _, _):
                                    upload.responseObject { (response: Alamofire.Response<ContentIDResponse,NSError>) in
                                        if let contentIDResponse = response.result.value{
                                            callback(error: nil, response: contentIDResponse)
                                        } else {
                                            callback(error: nil, response: nil)
                                        }
                                    }
                                case .Failure(let encodingError):
                                    callback(error: encodingError, response: nil)
                                }
            })
        }
    }
}

class TagRequester: Requester {
    
    let contentType = "application/json"
    
    func makeRequest(request: Request, completion callback: (error: ErrorType?, response: Mappable?) -> Void){
        
        guard let request = request as? TagRequest else {
            return
        }
        
        switch request.requestType {
        case .GET():
            Alamofire.request(.GET, request.requestURL).authenticate(user: request.username, password: request.password)
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



