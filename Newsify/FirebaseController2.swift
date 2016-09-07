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

    func deletePost(with id: String){
        let postRef = References.PhotoRef.child(id)
        postRef.setValue(nil)
        
        let uid = getUID()!
        
        let userRef = References.UserRef.child(uid).child(ReferenceLabels.UserPosts)
        userRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            guard var posts = snapshot.value as? [String] else {
                return
            }
            posts.removeObject(id)
            userRef.setValue(posts)
        })
        
        let storageRef = References.PhotoStorageRef.child("\(id).png")
        storageRef.deleteWithCompletion { (error) in
        }
        
        let notifRef = References.UserRef.child(uid).child(ReferenceLabels.Notifications)
        notifRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let notifs = snapshot.value as? [String: AnyObject] else { return }
            
            for (notifID, propDic) in notifs{
                guard let props = propDic as? [String: String] else {
                    continue
                }
                
                if props[ReferenceLabels.NotificationLabels.Target] == id {
                    notifRef.child(notifID).setValue(nil)
                }
            }
        })
        
    }
    
    func getPost(with id: String, completion callback: (FeedPost) -> Void){
        
        let selfid = getUID()!
        let ref = References.PhotoRef.child(id)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let post = snapshot.value as? [String: AnyObject] else { return }
            
            guard let ownerID = post[ReferenceLabels.PostOwner] as? String else { return }
            
            var likers: [String] = []
            var likerCount = 0
            var ownerName: String?
            var liked = false
            var tags: [String] = []
            self.getUsername(with: ownerID, completion: { (username) in
                ownerName = username
                
                if let likerPeople = post[ReferenceLabels.Likers] as? [String]{
                    likers = likerPeople
                    likerCount = likers.count
                }
                
                if let photoTags = post[ReferenceLabels.PostTags] as? [String]{
                    tags = photoTags
                }
                
                liked = likers.contains(selfid)
                
                let singlePost = FeedPost(ownerUsername: ownerName!, ownerID: ownerID, id: id, tags: tags, likers: likers, likeCount: likerCount, isAlreadyLiked: liked)
                
                callback(singlePost)
            })
        })
    }
    
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
    
    func changeLanguage(identifier: LanguageIdentifier, completion callback: () -> Void){
        let language = identifier.rawValue
        guard let uid = getUID() else { return }
        
        let langRef = References.UserRef.child(uid).child(ReferenceLabels.Language)
        langRef.setValue(language)
        lang = identifier.rawValue
        callback()
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