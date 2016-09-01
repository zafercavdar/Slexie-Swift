//
//  FirebaseController2.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation

extension FirebaseController {

    func setAccountPrivacy(privacy: Privacy){
        
        var privacyString: String
        switch privacy {
        case .Private:
            privacyString = "Private"
        case .Public:
            privacyString = "Public"
        }
        
        guard let uid = getUID() else { return }
        
        let userRef = References.UserRef.child(uid)
        let update = [ReferenceLabels.ProfileType : privacyString]
        userRef.updateChildValues(update)
        
        let photoRef = References.PhotoRef
        
        photoRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let dic = snapshot.value as? [String: AnyObject] else { return }
            
            var updateDic: [String: String] = [:]
            
            let keys = dic.keys
            for key in keys {
                if key.hasSuffix(uid){
                    updateDic["\(key)/\(ReferenceLabels.PostPrivacy)"] = privacyString
                }
            }
            
            photoRef.updateChildValues(updateDic)
        })
        
    }
    
}