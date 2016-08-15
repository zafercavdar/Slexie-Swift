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
            }else{
                print("Signed up with uid", user!.uid)
                self.cloneUserDetails(user!, username: username, password: password, profileType: profileType)
                self.signInWith(username: username, password: password, enableNotification: false, completionHandler: { (Void) in
                })
            }
            
            completionHandler(error: error)
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
        
        if let uid = uidNo as String!{
            print("getUID says: \(uid)")
            let photoRef = References.PhotoRef.child(uniqueID)
            
            photoRef.child(ReferenceLabels.PostTags.rawValue).setValue(tags)
            photoRef.child(ReferenceLabels.PostOwner.rawValue).setValue(uid)
            photoRef.child(ReferenceLabels.PostPrivacy.rawValue).setValue("Public")
            photoRef.child(ReferenceLabels.Likers.rawValue).setValue([])
            
            let userRef = References.UserRef.child(uid)
            
            getPhotoCount({ (count) in
                userRef.updateChildValues([ReferenceLabels.PostCount.rawValue : count+1])
            })
            
            userRef.updateChildValues([ReferenceLabels.UserTags.rawValue : tags])
            userRef.updateChildValues([ReferenceLabels.UserPosts.rawValue: uniqueID])

        } else {
            print("No users are identified.")
        }

    }
    
    func getAccountTags(completion: [String] -> Void) {
        let ref = References.UserRef.child(getUID()!).child(ReferenceLabels.UserTags.rawValue)
        
        _ = ref.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let tags = snapshot.value as? [String] {
                completion(tags)
            } else {
                completion([])
            }
        })
    }
    
    func getAccountPosts(completion: [String] -> Void) {
        let ref = References.UserRef.child(getUID()!).child(ReferenceLabels.UserPosts.rawValue)
        
        _ = ref.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let photos = snapshot.value as? [String]{
                completion(photos)
            } else {
                completion([])
            }
        })
    }
    
    func getPhotosRelatedWith(tag: String, completion: [String: String] -> Void){
        
        
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
        
        _  = ref.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
                let count = snapshot.value as! Int
                callback(count)
            }
        )
    }
    
    func getCurrentUser() -> FIRUser?{
        return FIRAuth.auth()?.currentUser
    }
    
    
    private func cloneUserDetails(fbUser: FIRUser!, username: String, password: String, profileType: String ){
        
        let ref = References.UserRef.child(fbUser!.uid)
        ref.child(ReferenceLabels.Username.rawValue).setValue(username)
        ref.child(ReferenceLabels.Password.rawValue).setValue(password)
        ref.child(ReferenceLabels.PostCount.rawValue).setValue(0)
        ref.child(ReferenceLabels.PhotoIDS.rawValue).setValue([])
        ref.child(ReferenceLabels.UserTags.rawValue).setValue([])
        ref.child(ReferenceLabels.UserPosts.rawValue).setValue([])
        ref.child(ReferenceLabels.ProfileType.rawValue).setValue(profileType)
    }
}

extension FBNetworkingController {

    enum References {
        static let MainRef = FIRDatabase.database().reference()
        static let UserRef = MainRef.child("users")
        static let PhotoRef = MainRef.child("photos")
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


