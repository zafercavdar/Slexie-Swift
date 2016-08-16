//
//  PhotoAnalyzeService.swift
//  Slexie
//
//  Created by Zafer Cavdar on 12/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import Alamofire

class PhotoAnalyzeService {
    
    enum API{
        static let key = "acc_d564dcda17e432d"
        static let secret = "f7573c7958226776ab1e22c0542604ed"
        static let endPoint = "https://api.imagga.com"
        static let authenticationToken = "Basic YWNjX2Q1NjRkY2RhMTdlNDMyZDpmNzU3M2M3OTU4MjI2Nzc2YWIxZTIyYzA1NDI2MDRlZA=="
    }
    
    let threshold = 25.00
    let maxTagNumber = 10

    func findBackgroundColorWithContentID(contentID: String, completion: (color: String) -> Void) {
        //let imageURL = "http://imagga.com/static/images/categorization/car.jpg"
        //let requestURL = "\(APIEndPoint)/v1/colors?url=\(imageURL)"
        let requestURL = "\(API.endPoint)/v1/colors?content=\(contentID)"
        
        var colorString = ""
        
        Alamofire.request(.GET, requestURL).authenticate(user: API.key, password: API.secret)
            .validate(contentType: ["application/json"]).responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let color = json["results"][0]["info"]["background_colors"][0]["closest_palette_color_parent"]
                        colorString = String(color.description)
                        print("JSON Background Color: \(colorString)")
                        completion(color: colorString)
                    }
                case .Failure(let error):
                    print("FAILED while finding background color \(error)")
                }
        }
    }
    
    func uploadPhotoGetContentID(imageData: NSData, completion: (id:String) -> Void){
        let uploadURL = "https://api.imagga.com/v1/content"
        
        // Begin upload
        Alamofire.upload(.POST, uploadURL,headers: ["Authorization": API.authenticationToken],
                         multipartFormData: { multipartFormData in
                        
                            // import image to request
                         
                            multipartFormData.appendBodyPart(data: imageData, name: "file", fileName: "myImage.png", mimeType: "image/png")
                        
            },
                         encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .Success(let upload, _, _):
                                upload.responseJSON { response in
                                    if let value = response.result.value{
                                        let json = JSON(value)
                                        //print(json)
                                        let statusString = String(json["status"].description)
                                        if statusString == "success"{
                                            let id = String(json["uploaded"][0]["id"].description)
                                            completion(id: id)
                                        }
                                    }
                                }
                            case .Failure(let encodingError):
                                print(encodingError)
                            }
        })
    }
    
    func findRelatedTagsWith(contentID contentID: String, completion: (tags: [String]) -> Void){
        let requestURL = "\(API.endPoint)/v1/tagging?content=\(contentID)" // via content ID
        
        var possibleTags: [String: Double] = [:]
        var tagNames: [String] = []
        
        Alamofire.request(.GET, requestURL).authenticate(user: API.key, password: API.secret)
            .validate(contentType: ["application/json"]).responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let tags = json["results"][0]["tags"]
                        
                        
                        for i in 0...tags.count{
                            let tag = String(tags[i]["tag"].description)
                            let confidence = Double(tags[i]["confidence"].description)
                            if confidence > self.threshold && tagNames.count < self.maxTagNumber {
                                possibleTags[tag] = confidence
                                tagNames.append(tag)
                            }
                        }
                        print("JSON Tags: \(tagNames)")
                        completion(tags: tagNames)
                        
                    }
                case .Failure(let error):
                    print("FAILED while finding tags \(error)")
                }
        }
    }
    
    func findRelatedTagsWith(url url: String, completion: (tags: [String]) -> Void){
        let requestURL = "\(API.endPoint)/v1/tagging?url=\(url)"
        
        var possibleTags: [String: Double] = [:]
        var tagNames: [String] = []
        
        Alamofire.request(.GET, requestURL).authenticate(user: API.key, password: API.secret)
            .validate(contentType: ["application/json"]).responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let tags = json["results"][0]["tags"]
                        
                        
                        for i in 0...tags.count{
                            let tag = String(tags[i]["tag"].description)
                            let confidence = Double(tags[i]["confidence"].description)
                            if confidence > self.threshold && tagNames.count < self.maxTagNumber{
                                possibleTags[tag] = confidence
                                tagNames.append(tag)
                            }
                        }
                        print("JSON Tags: \(tagNames)")
                        completion(tags: tagNames)
                        
                    }
                case .Failure(let error):
                    print("FAILED while finding tags \(error)")
                }
        }
    }

}
