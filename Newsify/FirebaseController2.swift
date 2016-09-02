//
//  FirebaseController2.swift
//  Slexie
//
//  Created by Zafer Cavdar on 01/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import Firebase

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
    
    func changePassword(oldPassword: String, newPassword: String, completion callback: (NSError?) -> Void){
        
        guard let uid = self.getUID() else { return }
        
        let usernameRef = References.UserRef.child(uid).child(ReferenceLabels.Username)
        
        usernameRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let username = snapshot.value as! String
            self.signInWith(username: username, password: oldPassword, enableNotification: false, completionHandler: { (error) in
                if (error == nil){
                    
                    self.getCurrentUser()?.updatePassword(newPassword, completion: { (error) in
                        
                        if (error == nil){
                            let userRef = References.UserRef.child(uid)
                            let update = [ReferenceLabels.Password : newPassword]
                            userRef.updateChildValues(update)
                        }
                        
                        callback(error)
                    })

                } else {
                    callback(error)
                }
            })
        })
    }
    
    func isPasswordCorrect(oldPassword: String, completion callback: (isCorrect: Bool) -> Void) {
        
        guard let uid = self.getUID() else { return }
        
        let passwordRef = References.UserRef.child(uid).child(ReferenceLabels.Password)
        passwordRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            guard let password = snapshot.value as? String else { return }
            
            callback(isCorrect: password == oldPassword)
        })
    }
}