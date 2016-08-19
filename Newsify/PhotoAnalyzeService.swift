//
//  PhotoAnalyzeService.swift
//  Slexie
//
//  Created by Zafer Cavdar on 12/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

protocol PhotoAnalyzeService {
    
    func findBackgroundColorWithContentID(contentID: String, completion: (color: String) -> Void)
    func findRelatedTagsWith(contentID contentID: String, completion: (tags: [String]) -> Void)
    func findRelatedTagsWith(url url: String, completion: (tags: [String]) -> Void)
    
}
