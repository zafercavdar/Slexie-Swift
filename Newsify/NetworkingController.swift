//
//  NetworkingController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkingController {
    
    func uploadPhoto(image: NSData, tags: [String], callback: (error: NSError?, photoID: String, url: String) -> Void)
    
    func downloadPhoto(with photoID: String, completion callback: (UIImage?, NSError?) -> Void)
        
    func getAccountTags(completion: [String] -> Void)
    
    func getPhotosRelatedWith(tags: [String], completion: [FeedPost] -> Void)
    
    func getProfilePosts(completion callback: [ProfilePost] -> Void)
    
}