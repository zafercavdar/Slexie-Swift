//
//  SetttingsViewModel.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

class SettingsViewModel {

    
    private let controller = FirebaseController()
    
    let sectionHeaders = ["Account", "Preferences", "About", "Don't do it"]
    let sections: [[String]] = [ ["Edit profile", "Change password", "Private account"],
                                 ["Language"],
                                 ["Privacy Policy"],
                                 ["Log out"]]
    
    
    func setPrivacy(privacy: Privacy){
        controller.setAccountPrivacy(privacy)
    }
    
    func isPrivateAccount (callback: (isPrivate: Bool) -> Void){
        controller.getAccountPrivacy { (privacy) in
            callback(isPrivate: privacy == "Private")
        }
    }
}