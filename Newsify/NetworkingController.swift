//
//  NetworkingController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

protocol NetworkingController {
    
    func signInWith(username username: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void)
    
    func signInWith(email email: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void)
    
    func signUp(email: String, username: String, password: String, profileType: String, completionHandler: (error: NSError?) -> Void)
    
    func uploadPhoto(image: NSData, tags: [String], callback: (error: NSError?, photoID: String, url: String) -> Void)
    
    //func saveTagsFor(photo contentID: String, tags: [String])
    
    func getAccountTags(completion: [String] -> Void)
    
    func getPhotosRelatedWith(tags: [String], completion: [String: FeedPost] -> Void)
    
    func signOut(callback: Void->Void)
    
    func getUID() -> String?

}