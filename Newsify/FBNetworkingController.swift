//
//  FBNetworkingController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FBNetworkingController: NetworkingController {
    
    let appURL = "hackify-a48e3.firebaseio.com"
    
    
    // MARK: NetworkingController Methods
    
    func signInWith(username username: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void){
        
        let email = username + "@slexie.com"

        signInWith(email: email, password: password, enableNotification: enableNotification) { (error) in
            completionHandler(error: error)
        }
    }
    
    func signInWith(email email: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void){
        
        signOut { (Void) in
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if let error = error{
                print("Sign in failed.", error.localizedDescription)
            } else{
                print("Signed in with uid", user!.uid)
            }
            
            completionHandler(error: error)

        })

    }
    
    func signUp(email: String, username: String, password: String, profileType: String, completionHandler: (error: NSError?) -> Void) {
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            
            if let e = error {
                print("Sign up failed.", e.localizedDescription)
                completionHandler(error: error)
            }else{
                print("Signed up with uid", user!.uid)
                self.cloneUserDetails(user!, username: username, password: password, profileType: profileType)
                self.signInWith(username: username, password: password, enableNotification: false, completionHandler: { (Void) in
                    completionHandler(error: error)
                })
            }
        })

    }
    
    func uploadPhoto(image: NSData, tags: [String], callback: (error: NSError?, photoID: String, url: String) -> Void){
        let storageRef = FIRStorage.storage().reference()
        let uniqueIDGenerator = UniqueIDGenerator()
        
        if let userid = getCurrentUser()?.uid {
            let photoID = uniqueIDGenerator.generatePhotoID(userid)
            let photoRef = storageRef.child("images/\(photoID).png")
            _  = photoRef.putData(image, metadata: nil) { metadata, error in
                
                var downloadURL: String = ""
                
                if error != nil {
                    print("Problem while uploading, error: \(error!.localizedDescription)")
                } else {
                    downloadURL = (metadata!.downloadURL()?.absoluteURL.absoluteString)!
                    print("DOWNLOAD URL: \n\(downloadURL)\n")
                    self.saveTagsFor(photo: photoID, tags: tags)
                }
                
                callback(error: error,photoID: photoID, url: downloadURL)
            }
        }
    }
    
    private func saveTagsFor(photo uniqueID: String, tags: [String]) {
        let uidNo = getUID()
        var profileType = ""
        
        getAccountPrivacy { (privacy) in
            profileType = privacy
        }
        
        if let uid = uidNo as String!{
            print("getUID says: \(uid)")
            let photoRef = References.PhotoRef.child(uniqueID)
            
            photoRef.child(ReferenceLabels.PostTags.rawValue).setValue(tags)
            photoRef.child(ReferenceLabels.PostOwner.rawValue).setValue(uid)
            photoRef.child(ReferenceLabels.PostPrivacy.rawValue).setValue(profileType)
            photoRef.child(ReferenceLabels.Likers.rawValue).setValue([])
            
            let userRef = References.UserRef.child(uid)
            
            getPhotoCount({ (count) in
                userRef.updateChildValues([ReferenceLabels.PostCount.rawValue : count+1])
            })
            
            getAccountTags({ (oldTags) in
                userRef.updateChildValues([ReferenceLabels.UserTags.rawValue : oldTags + tags])
            })
            
            getAccountPosts({ (oldPosts) in
                userRef.updateChildValues([ReferenceLabels.UserPosts.rawValue: oldPosts + [uniqueID]])
            })
            

        } else {
            print("No users are identified.")
        }

    }
    
    func getAccountTags(completion: [String] -> Void) {
        let ref = References.UserRef.child(getUID()!).child(ReferenceLabels.UserTags.rawValue)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let tags = snapshot.value as? [String] {
                completion(tags)
            } else {
                completion([])
            }
        })
    }
    
    func getAccountPosts(completion: [String] -> Void) {
        let ref = References.UserRef.child(getUID()!).child(ReferenceLabels.UserPosts.rawValue)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let photos = snapshot.value as? [String]{
                completion(photos)
            } else {
                completion([])
            }
        })
    }
    
    func getPhotosRelatedWith(tag: String, completion: [String: String] -> Void){
        
        var result: [String: String] = [:]
        
        
        let ref = References.PhotoRef
        _ = ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            guard let postDic = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            for (id, propertyDic) in postDic {
                
                guard let privacy = propertyDic[ReferenceLabels.PostPrivacy.rawValue] as? String where privacy == "Public" else {
                    continue
                }
                
                guard let tags = propertyDic[ReferenceLabels.PostTags.rawValue] as? [String] else {
                    continue
                }
                
                guard tags.contains(tag) else {
                    continue
                }
                
                if let owner = propertyDic[ReferenceLabels.PostOwner.rawValue] as? String {
                    result[id] = owner
                }
                
            }
            
            completion(result)
        })
        
    }
    
    func signOut(callback: Void -> Void) {
        try! FIRAuth.auth()!.signOut()
        callback()
    }
    
    func getUID() -> String? {
        return getCurrentUser()?.uid
    }
    
    
    // MARK: Private methods
    
    private func getPhotoCount(callback: (Int) -> Void) {
        
        let ref = References.UserRef.child(getUID()!).child(ReferenceLabels.PostCount.rawValue)
        
        ref.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            let count = snapshot.value as! Int
            callback(count)
        })
    }
    
    func getCurrentUser() -> FIRUser?{
        return FIRAuth.auth()?.currentUser
    }
    
    
    private func cloneUserDetails(fbUser: FIRUser!, username: String, password: String, profileType: String ){
        
        let ref = References.UserRef.child(fbUser!.uid)
        
        let user = [ ReferenceLabels.Username.rawValue: username,
                     ReferenceLabels.Password.rawValue: password,
                     ReferenceLabels.PostCount.rawValue: 0,
                     ReferenceLabels.PhotoIDS.rawValue: [],
                     ReferenceLabels.UserTags.rawValue: [],
                     ReferenceLabels.UserPosts.rawValue: [],
                     ReferenceLabels.ProfileType.rawValue: profileType]
        
        ref.updateChildValues(user as [NSObject : AnyObject])
    }
    
    private func getAccountPrivacy(callback: (privacy: String) -> Void){
        let ref = References.UserRef.child(getUID()!).child(ReferenceLabels.ProfileType.rawValue)
        ref.observeSingleEventOfType(.Value , withBlock: { (snapshot) in
            let type = snapshot.value as! String
            callback(privacy: type)
        })
    }
}

extension FBNetworkingController {

    enum References {
        
        static let DatabaseRef = FIRDatabase.database().reference()
        static let UserRef = DatabaseRef.child("users")
        static let PhotoRef = DatabaseRef.child("photos")
        static let StorageRef = FIRStorage.storage().reference()
    }
    
    enum ReferenceLabels: String {
        case Username = "username"
        case Password = "password"
        case PostCount = "postCount"
        case PhotoIDS = "photoIDs"
        case UserTags = "alltags"
        case UserPosts = "all-photos"
        case ProfileType = "profile-type"
        
        case PostOwner = "owner"
        case PostTags = "tags"
        case PostPrivacy = "privacy"
        case Likers = "likers"
    }
    
}

extension FBNetworkingController {
    
    func fakeSignUp(uid: String,email: String, username: String, password: String, profileType: String) {
        self.fakeCloneUserDetails(uid, username: username, password: password, profileType: profileType)
    }
    
    func fakeCloneUserDetails(uid: String, username: String, password: String, profileType: String ){
        
        let ref = References.UserRef.child(uid)
        
        let user = [ ReferenceLabels.Username.rawValue: username,
                     ReferenceLabels.Password.rawValue: password,
                     ReferenceLabels.PostCount.rawValue: 0,
                     ReferenceLabels.PhotoIDS.rawValue: [],
                     ReferenceLabels.UserTags.rawValue: [],
                     ReferenceLabels.UserPosts.rawValue: [],
                     ReferenceLabels.ProfileType.rawValue: profileType]
        
        ref.updateChildValues(user as [NSObject : AnyObject])
    }


    func fakeUpload(uid: String, imageid: String, tags: [String]){
        self.fakeSaveTagsFor(uid, uniqueID: imageid, tags: tags)
    }
    
    func fakeSaveTagsFor(fakeuid: String,uniqueID: String, tags: [String]) {
        
        let photoRef = References.PhotoRef.child(uniqueID)
        
        photoRef.child(ReferenceLabels.PostTags.rawValue).setValue(tags)
        photoRef.child(ReferenceLabels.PostOwner.rawValue).setValue(fakeuid)
        photoRef.child(ReferenceLabels.PostPrivacy.rawValue).setValue("Public")
        photoRef.child(ReferenceLabels.Likers.rawValue).setValue([])
        
        let userRef = References.UserRef.child(fakeuid)
        
        fakeGetPhotoCount(fakeuid, callback: { (count) in
            userRef.updateChildValues([ReferenceLabels.PostCount.rawValue : count+1])
        })
        
        fakeGetAccountTags(fakeuid, completion: { (oldTags) in
            userRef.updateChildValues([ReferenceLabels.UserTags.rawValue : oldTags + tags])
        })
        
        fakeGetAccountPosts(fakeuid, completion: { (oldPosts) in
            userRef.updateChildValues([ReferenceLabels.UserPosts.rawValue: oldPosts + [uniqueID]])
        })    
    }
    
    func fakeGetPhotoCount(uid: String, callback: (Int) -> Void) {
        
        let ref = References.UserRef.child(uid).child(ReferenceLabels.PostCount.rawValue)
        
        ref.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            let count = snapshot.value as! Int
            callback(count)
        })
    }
    
    func fakeGetAccountTags(uid: String, completion: [String] -> Void) {
        let ref = References.UserRef.child(uid).child(ReferenceLabels.UserTags.rawValue)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let tags = snapshot.value as? [String] {
                completion(tags)
            } else {
                completion([])
            }
        })
    }
    
    func fakeGetAccountPosts(uid: String, completion: [String] -> Void) {
        let ref = References.UserRef.child(uid).child(ReferenceLabels.UserPosts.rawValue)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let photos = snapshot.value as? [String]{
                completion(photos)
            } else {
                completion([])
            }
        })
    }



}


