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
    
    let sectionHeaders = [localized("Account"), localized("Preferences"), localized("About"), localized("App")]
    let sections: [[String]] = [ [localized("EditProfile"), localized("ChangePassword"), localized("PrivateAccount")],
                                 [localized("Language")],
                                 [localized("PrivacyPolicy")],
                                 [localized("LogOut")]]
    
    
    func setPrivacy(privacy: Privacy){
        controller.setAccountPrivacy(privacy)
    }
    
    func isPrivateAccount (callback: (isPrivate: Bool) -> Void){
        controller.getAccountPrivacy { (privacy) in
            callback(isPrivate: privacy == "Private")
        }
    }
}