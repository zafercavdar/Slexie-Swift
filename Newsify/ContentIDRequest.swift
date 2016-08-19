//
//  ContentIDRequest.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class ContentIDRequest: Request {
    
    func request(requestType: RequestType<NSData>, requestURL: String, username: String, password: String, authToken: String,completion callback: (error: ErrorType?, response: Mappable?) -> Void) {
        
        switch requestType {
        case .GET():
            print("ContentIDRequest is a type of POST request.")
        case .POST(let imageData):
            Alamofire.upload(.POST, requestURL,headers: ["Authorization": authToken],
                             multipartFormData: { multipartFormData in
                                
                                multipartFormData.appendBodyPart(data: imageData, name: "file", fileName: "myImage.png", mimeType: "image/png")
                                
                },
                             encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .Success(let upload, _, _):
                                    upload.responseObject { (response: Response<ContentIDResponse,NSError>) in
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
