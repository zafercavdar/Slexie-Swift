//
//  AuthenticationController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 22/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

protocol AuthenticationController {
    
    func signInWith(username username: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void)
    
    func signInWith(email email: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void)
    
    func signUp(email: String, username: String, password: String, profileType: String, completionHandler: (error: NSError?) -> Void)
    
    func signOut(callback: Void->Void)
    
    func getUID() -> String?


}