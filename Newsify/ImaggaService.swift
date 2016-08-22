//
//  ImaggaService.swift
//  Slexie
//
//  Created by Zafer Cavdar on 19/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ImaggaService: PhotoAnalyzeService {

    private struct API{
        static let key = "acc_d564dcda17e432d"
        static let secret = "f7573c7958226776ab1e22c0542604ed"
        static let endPoint = "https://api.imagga.com"
        static let authenticationToken = "Basic YWNjX2Q1NjRkY2RhMTdlNDMyZDpmNzU3M2M3OTU4MjI2Nzc2YWIxZTIyYzA1NDI2MDRlZA=="
    }
    
    private struct ConsString {
        static let contentType = "application/json"
    }
    
    private let threshold = 25.00
    private let maxTagNumber = 6
    
    func findBackgroundColorWithContentID(contentID: String, completion: (color: String) -> Void) {
        //let requestURL = "\(APIEndPoint)/v1/colors?url=\(imageURL)"
        let requestURL = "\(API.endPoint)/v1/colors?content=\(contentID)"
        
        var colorString = ""
        
        Alamofire.request(.GET, requestURL).authenticate(user: API.key, password: API.secret)
            .validate(contentType: [ConsString.contentType]).responseJSON { response in
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
        let requestURL = "\(API.endPoint)/v1/content"
        
        let requester = ContentIDRequester()
        let request = Request(requestType: .POST(imageData), requestURL: requestURL, username: API.key, password: API.secret, authToken: API.authenticationToken)
        
        requester.makeRequest(request) { (error, response) in
            
            guard error == nil, let response = response, let idresponse = (response as? ContentIDResponse), let id = idresponse.id else {
                return
            }
            completion(id: id)
        }
    }
    
    func findRelatedTagsWith(contentID contentID: String, completion: (tags: [String]) -> Void){
        let requestURL = "\(API.endPoint)/v1/tagging?content=\(contentID)"
        
        let requester = TagRequester()
        let request = Request(requestType: .GET(), requestURL: requestURL, username: API.key, password: API.secret, authToken: API.authenticationToken)
        
        requester.makeRequest(request) { [weak self] (error, response) in
                
                guard let strongSelf = self else { return }
                
                guard error == nil, let response = response, let tagResponse = (response as? TagResponse), let tags = tagResponse.tags else {
                    completion(tags: [])
                    return
                }
            
                completion(tags: strongSelf.getHighlyTrustedTags(tags))
        }
    }
    
    func findRelatedTagsWith(url url: String, completion: (tags: [String]) -> Void){
        let requestURL = "\(API.endPoint)/v1/tagging?url=\(url)"
        
        let requester = TagRequester()
        let request = Request(requestType: .GET(), requestURL: requestURL, username: API.key, password: API.secret, authToken: API.authenticationToken)
        
        requester.makeRequest(request) { [weak self] (error, response) in
            
            guard let strongSelf = self else { return }
            
            guard error == nil, let response = response, let tagResponse = (response as? TagResponse), let tags = tagResponse.tags else {
                completion(tags: [])
                return
            }
            
            completion(tags: strongSelf.getHighlyTrustedTags(tags))
        }
    }
    
    private func getHighlyTrustedTags(tags: [Tag]) -> [String]{
        var tagNames: [String] = []
        
        for i in 0..<tags.count{
            let tag = tags[i].tag
            let confidence = tags[i].confidence
            if confidence > self.threshold && tagNames.count < self.maxTagNumber {
                tagNames.append(tag!)
            } else if tagNames.count < self.maxTagNumber {
                break
            }
        }
        
        return tagNames

    }
}
