//
//  FBNetworkingController.swift
//  Slexie
//
//  Created by Zafer Cavdar on 11/08/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit

enum CallbackResult {
    case Success
    case Failed
}

protocol NetworkingController {
    
    func uploadPhoto(image: NSData, tags: [String], callback: (error: NSError?, photoID: String, url: String) -> Void)
    func downloadPhoto(with photoID: String, completion callback: (UIImage?, NSError?) -> Void)
    func getAccountTags(completion: [String] -> Void)
    func getPhotosRelatedWith(tags: [String], count: Int, completion: [FeedPost] -> Void)
    func getProfilePosts(completion callback: [FeedPost] -> Void)
    func fetchUserLanguage(completion callback: (identifier: String) -> Void)
    func photoLiked(imageid: String, callback: (CallbackResult) -> Void)
    func photoUnliked(imageid: String, callback: (CallbackResult) -> Void)
    
    func pushNotification(notification: Notification, completion callback: () -> Void)
    func removeNotification(notification: Notification, completion callback: () -> Void)
    func fetchNotifications(completion callback: [Notification] -> Void)
    func getUsername(with uid: String, completion callback: (username: String) -> Void)
    
}

protocol LoginController {
    func signInWith(username username: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void)
    func signInWith(email email: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void)
}

protocol LogOutController {
    func signOut(callback: Void->Void)
}

protocol SignUpController {
    func signUp(email: String, username: String, password: String, profileType: String, language: String, completionHandler: (error: NSError?) -> Void)
}

protocol AuthenticationController: SignUpController, LogOutController, LoginController {
    func getUID() -> String?
}

class FirebaseController: NetworkingController, AuthenticationController {
    
    let appURL = "hackify-a48e3.firebaseio.com"
    
    private struct ConsString {
        static let domain = "@slexie.com"
    }
    
    struct References {
        static let DatabaseRef = FIRDatabase.database().reference()
        static let UserRef = DatabaseRef.child("users")
        static let PhotoRef = DatabaseRef.child("photos")
        static let StorageRef = FIRStorage.storage().reference()
        static let PhotoStorageRef = References.StorageRef.child("images")
    }
    
    struct ReferenceLabels {
        static let Username = "username"
        static let Password = "password"
        static let PostCount = "postCount"
        static let PhotoIDS = "photoIDs"
        static let UserTags = "alltags"
        static let UserPosts = "all-photos"
        static let ProfileType = "profile-type"
        static let Language = "language"
        static let Notifications = "notifications"
        
        static let PostOwner = "owner"
        static let PostTags = "tags"
        static let PostPrivacy = "privacy"
        static let Likers = "likers"
        
        struct NotificationLabels{
            static let Who = "Who"
            static let Target = "Target"
            static let Action = "Action"
        }
        
        struct ActionLabels{
            static let Like = "Liked"
            static let Comment = "Comment"
        }
    }

    
    // MARK: AuthenticationController Methods
    
    func signInWith(username username: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void){
        
        let email = username + ConsString.domain

        signInWith(email: email, password: password, enableNotification: enableNotification) { (error) in
            completionHandler(error: error)
        }
    }
    
    func signInWith(email email: String, password: String, enableNotification: Bool, completionHandler: (error: NSError?) -> Void){
        
        signOut {}
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error == nil{
                print("Signed in with uid", user!.uid)
            }
            
            completionHandler(error: error)

        })

    }
    
    func signUp(email: String, username: String, password: String, profileType: String, language: String, completionHandler: (error: NSError?) -> Void) {
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { [weak self] (user, error) in
            
            guard let strongSelf = self else { return }
            
            if error != nil {
                completionHandler(error: error)
            }else{
                print("Signed up with uid", user!.uid)
                strongSelf.cloneUserDetails(user!, username: username, password: password, profileType: profileType, language: language)
                strongSelf.signInWith(username: username, password: password, enableNotification: false, completionHandler: { (Void) in
                    completionHandler(error: error)
                })
            }
        })
    }
    
    func signOut(callback: Void -> Void) {
        try! FIRAuth.auth()!.signOut()
        callback()
    }
    
    func getUID() -> String? {
        return getCurrentUser()?.uid
    }
    
    func getCurrentUser() -> FIRUser?{
        return FIRAuth.auth()?.currentUser
    }


    // MARK: NetworkingController Methods
    
    func fetchNotifications(completion callback: [Notification] -> Void){
        
        
        struct MissingNotification {
            var ownerID: String
            var targetID: String
            var whoID: String
            var type: NotificationType
        }
        
        var firstResults: [MissingNotification] = []
        var results: [Notification] = []
        
        guard let uid = getUID() else { return }
        
        let notificationRef = References.UserRef.child(uid).child(ReferenceLabels.Notifications).queryLimitedToLast(50)
        
        notificationRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            guard let notificationDic = snapshot.value as? [String: AnyObject] else {
                callback([])
                return
            }
            
            let sortedDic = notificationDic.sort { $0.0 < $1.0 }
            
            for (_, propDic) in sortedDic {
                guard let dic = propDic as? [String: String] else {
                    callback([])
                    return
                }
                
                let who = dic[ReferenceLabels.NotificationLabels.Who]
                let target = dic[ReferenceLabels.NotificationLabels.Target]
                let action = dic[ReferenceLabels.NotificationLabels.Action]
                
                var notificationType: NotificationType
                switch action {
                case ReferenceLabels.ActionLabels.Like?:
                    notificationType = NotificationType.Liked
                case ReferenceLabels.ActionLabels.Comment?:
                    notificationType = NotificationType.Commented
                default:
                    notificationType = NotificationType.Liked
                }
                
                let notification = MissingNotification(ownerID: uid, targetID: target!, whoID: who!, type: notificationType)
                firstResults += [notification]
            }
            
            
            let ref = References.UserRef
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let allUsers = snapshot.value as? [String: AnyObject] else { return }
                
                for result in firstResults {
                    print(result.whoID)
                    guard let props = (allUsers[result.whoID] as? [String: AnyObject]),
                        let username = props[ReferenceLabels.Username] as? String else { return }
                    
                    let notification = Notification(ownerID: result.ownerID, targetID: result.targetID, doneByUserID: result.whoID, doneByUsername: username, type: result.type)
                    
                    results += [notification]
                }
                
                callback(results)
            })
        })
    }
    
    func pushNotification(notification: Notification, completion callback: () -> Void){
        
        let generator = UniqueIDGenerator()
        let notificationID = generator.generateNotificationID(notification)
        
        var action = ""
        
        switch notification.notificationType {
        case .Liked:
            action = ReferenceLabels.ActionLabels.Like
        case .Commented:
            action = ReferenceLabels.ActionLabels.Comment
        default:
            action = "Unknown"
        }
        
        let notificationRef = References.UserRef.child(notification.notificationOwnerID).child(ReferenceLabels.Notifications).child(notificationID)
        
        let batchUpdate = [ReferenceLabels.NotificationLabels.Who : notification.notificationDoneByUserID,
                           ReferenceLabels.NotificationLabels.Target : notification.notificationTargetID,
                           ReferenceLabels.NotificationLabels.Action : action]
        
        notificationRef.updateChildValues(batchUpdate)
        
        callback()
        
    }
    
    func removeNotification(notification: Notification, completion callback: () -> Void) {
        let notificationsRef = References.UserRef.child(notification.notificationOwnerID).child(ReferenceLabels.Notifications)
        
        notificationsRef.observeSingleEventOfType(.Value , withBlock:  { (snapshot) in
            guard let dic = snapshot.value as? [String: AnyObject] else {
                callback()
                return
            }
            
            var removalID: String = ""
            
            for (id, properties) in dic {
                guard properties is [String: String] else { continue }
                
                let target = properties[ReferenceLabels.NotificationLabels.Target] as! String
                let who = properties[ReferenceLabels.NotificationLabels.Who] as! String
                
                guard target == notification.notificationTargetID && who == notification.notificationDoneByUserID else {
                    continue
                }
                
                var notiAction = ""
                let action = properties[ReferenceLabels.NotificationLabels.Action] as! String
                
                switch notification.notificationType {
                case .Liked:
                    notiAction = ReferenceLabels.ActionLabels.Like
                case .Commented:
                    notiAction = ReferenceLabels.ActionLabels.Comment
                default:
                    notiAction = "Unknown"
                }
                
                guard action == notiAction else { continue }
                
                removalID = id
                notificationsRef.child(removalID).removeValueWithCompletionBlock({ (error, reference) in
                    callback()
                })
            }
            
            
            
        })
        
    }
    
    func fetchUserLanguage(completion callback: (identifier: String) -> Void) {
        
        guard let uid = getUID() else {
            callback(identifier: "nil")
            return
        }
        
        let languageRef = References.UserRef.child(uid).child(ReferenceLabels.Language)
        
        languageRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            
            guard let identifier = snapshot.value as? String else {
                callback(identifier: "nil")
                return
            }
            
            callback(identifier: identifier)
        })
    }
    
    func uploadPhoto(image: NSData, tags: [String], callback: (error: NSError?, photoID: String, url: String) -> Void){
        let storageRef = FIRStorage.storage().reference()
        let uniqueIDGenerator = UniqueIDGenerator()
        
        if let userid = getCurrentUser()?.uid {
            let photoID = uniqueIDGenerator.generatePhotoID(userid)
            let photoRef = storageRef.child("images/\(photoID).png")
            _  = photoRef.putData(image, metadata: nil) { [weak self] metadata, error in
            
                guard let strongSelf = self else { return }
                
                var downloadURL: String = ""
                
                if error != nil {
                    print("ERROR while uploading, error: \(error!.localizedDescription)")
                } else {
                    downloadURL = (metadata!.downloadURL()?.absoluteURL.absoluteString)!
                    print("DOWNLOAD URL: \n\(downloadURL)\n")
                    strongSelf.saveTagsFor(photo: photoID, tags: tags)
                }
                
                callback(error: error, photoID: photoID, url: downloadURL)
            }
        }
    }
    
    func getAccountTags(completion: [String] -> Void) {
        
        guard let uid = getUID() else {
            return
        }
        
        let ref = References.UserRef.child(uid).child(ReferenceLabels.UserTags)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let tags = snapshot.value as? [String] {
                completion(tags)
            } else {
                completion([])
            }
        })
    }
    
    func getPhotosRelatedWith(tags: [String], count: Int, completion: [FeedPost] -> Void){
        
        var posts: [FeedPost] = []
        
        let ref = References.PhotoRef.queryLimitedToLast(UInt(count))
        
        _ = ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            guard let postDic = snapshot.value as? [String: AnyObject] else {
                completion([])
                return
            }
            
            let sortedPostDic = postDic.sort { $0.0 < $1.0 }
            
            let userRef = References.UserRef
            userRef.observeSingleEventOfType(.Value, withBlock: { [weak self] (snapshot) in
                
                guard let userDic = snapshot.value as? [String: AnyObject] else {
                    completion([])
                    return
                }
                
                for (id, propertyDic) in sortedPostDic {
                    
                    // Public check
                    guard let privacy = propertyDic[ReferenceLabels.PostPrivacy] as? String where privacy == "Public" else {
                        continue
                    }
                    
                    guard let photoTags = propertyDic[ReferenceLabels.PostTags] as? [String] else {
                        continue
                    }
                    
                    
                    guard containsAny(photoTags,checkList: tags) else {
                        continue
                    }
                    
                    guard let ownerID = propertyDic[ReferenceLabels.PostOwner] as? String/* where owner != strongSelf.getUID() */ else {
                        
                        continue
                    }
                    
                    
                    var likers = propertyDic[ReferenceLabels.Likers] as? [String]
                    if likers == nil {
                        likers = []
                    }
                    
                    guard let atts = userDic[ownerID] as? [String: AnyObject], let username = atts[ReferenceLabels.Username] as? String else {
                        continue
                    }
                    
                    guard let uid = self?.getUID() else {
                        return
                    }
                    
                    let liked = likers!.contains(uid)
                    
                    let post = FeedPost(ownerUsername: username, ownerID: ownerID, id: id, tags: photoTags, likers: likers!, likeCount: likers!.count, isAlreadyLiked: liked)
                    posts.append(post)
                    
                }
                completion(posts)
                })
        })
    }
    
    func getProfilePosts(completion callback: [FeedPost] -> Void) {
        
        var profilePosts: [FeedPost] = []
        
        let uid = getUID()!
        
        getUsername(with: uid) { (username) in
            self.getAccountPosts { (postIDs) in
                let photoRef = References.PhotoRef
                photoRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                    
                    if let photos = snapshot.value as? [String: AnyObject] {
                        for postID in postIDs {
                            
                            var tags: [String]?
                            
                            guard let uid = self.getUID() else {
                                return
                            }
                            
                            tags = ((photos[postID] as! [String: AnyObject])[ReferenceLabels.PostTags] as? [String])
                            
                            if tags == nil {
                                tags = []
                            }
                            
                            var likeCount: Int
                            var liked: Bool
                            var likers = ((photos[postID] as! [String: AnyObject])[ReferenceLabels.Likers] as? [String])
                            
                            if likers == nil {
                                likers = []
                                likeCount = 0
                                liked = false
                            } else {
                                likeCount = likers!.count
                                liked = (likers?.contains(uid))!
                            }
                            
                            let post = FeedPost(ownerUsername: username, ownerID: uid, id: postID, tags: tags!, likers: likers!, likeCount: likeCount, isAlreadyLiked: liked)
                            profilePosts.append(post)
                            
                        }
                        callback(profilePosts)
                    } else {
                        callback([])
                    }
                })
            }

        }
        
    }
    
    func downloadPhoto(with photoID: String, completion callback: (UIImage?, NSError?) -> Void){
        let photoRef = References.PhotoStorageRef.child("\(photoID).png")
        
        let fileManager = NSFileManager.defaultManager()
        let localMainURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        let localURLString = (localMainURL?.absoluteString)! + "images/\(photoID).png"
        let localURL = NSURL(string: localURLString)
        
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let pURL = NSURL(fileURLWithPath: path)
        let filePath = pURL.URLByAppendingPathComponent("images/\(photoID).png").path!
        
        
        if fileManager.fileExistsAtPath(filePath){
            guard let data = NSData(contentsOfURL: localURL!), let image = UIImage(data: data) else { return }
            callback(image, nil)
            
        } else {
            _ = photoRef.writeToFile(localURL!) { (URL, error) -> Void in
                if (error != nil) {
                    callback(nil, error)
                } else {
                    guard let data = NSData(contentsOfURL: URL!), let image = UIImage(data: data) else {
                        return
                    }
                    
                    callback(image, error)
                }
            }
        }
    }
    
    func photoLiked(imageid: String, callback: (CallbackResult) -> Void){

        let uidNo = getUID()
        
        if let uid = uidNo as String!{
            let photoRef = References.PhotoRef.child(imageid)
            
            getLikers(photo: imageid, completion: { (likerList) in
                let array = likerList + [uid]
                let uniqueList = Array(Set(array))
                let dic = [ReferenceLabels.Likers : uniqueList]
                print(uniqueList)
                photoRef.updateChildValues(dic)
                callback(.Success)
            })
        } else {
            callback(.Failed)
        }
        
    }
    
    func photoUnliked(imageid: String, callback: (CallbackResult) -> Void){
        
        let uidNo = getUID()
        
        if let uid = uidNo as String!{
            let photoRef = References.PhotoRef.child(imageid)
            
            getLikers(photo: imageid, completion: { (likerList) in
                var likers = likerList
                likers.removeObject(uid)
                let uniqueList = Array(Set(likers))
                let dic = [ReferenceLabels.Likers : uniqueList]
                print(uniqueList)
                photoRef.updateChildValues(dic)
                callback(.Success)
            })
        } else {
            callback(.Failed)
        }
    }

    
    func getUsername(with uid: String, completion callback: (username: String) -> Void){
        
        let ref = References.UserRef.child(uid).child(ReferenceLabels.Username)
        ref.observeSingleEventOfType(.Value,  withBlock: { (snapshot) in
            let username = snapshot.value as! String
            callback(username: username)
        })
    }


    // MARK: Private methods
    
    private func getLikers(photo uniqueID: String, completion callback: [String] -> Void) {
        let photoRef = References.PhotoRef.child(uniqueID).child(ReferenceLabels.Likers)
        
        photoRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if let likers = snapshot.value as? [String] {
                callback(likers)
            } else { callback([]) }
            
        })
    }

    
    private func saveTagsFor(photo uniqueID: String, tags: [String]) {
        let uidNo = getUID()
        
        if let uid = uidNo as String!{
            let photoRef = References.PhotoRef.child(uniqueID)
            
            photoRef.child(ReferenceLabels.PostTags).setValue(tags)
            photoRef.child(ReferenceLabels.PostOwner).setValue(uid)
            
            getAccountPrivacy { (privacy) in
                photoRef.child(ReferenceLabels.PostPrivacy).setValue(privacy)
            }
            
            photoRef.child(ReferenceLabels.Likers).setValue([])
            
            let userRef = References.UserRef.child(uid)
            
            getPhotoCount({ (count) in
                userRef.updateChildValues([ReferenceLabels.PostCount : count+1])
            })
            
            getAccountTags({ (oldTags) in
                let set = Array(Set(oldTags + tags))
                userRef.updateChildValues([ReferenceLabels.UserTags : set])
            })
            
            getAccountPosts({ (oldPosts) in
                userRef.updateChildValues([ReferenceLabels.UserPosts: oldPosts + [uniqueID]])
            })
        }
    }
    
    
    private func getAccountPosts(completion: [String] -> Void) {
        
        guard let uid = getUID() else {
            return
        }
        
        let ref = References.UserRef.child(uid).child(ReferenceLabels.UserPosts)
        
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let photos = snapshot.value as? [String]{
                completion(photos)
            } else {
                completion([])
            }
        })
    }
    
    private func getPhotoCount(callback: (Int) -> Void) {
        
        guard let uid = getUID() else {
            return
        }
        
        let ref = References.UserRef.child(uid).child(ReferenceLabels.PostCount)
        
        ref.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if let count = snapshot.value as? Int {
                callback(count)
            }
        })
    }
    
    func getAccountPrivacy(callback: (privacy: String) -> Void){
        
        guard let uid = getUID() else {
            return
        }
        
        let ref = References.UserRef.child(uid).child(ReferenceLabels.ProfileType)
        ref.observeSingleEventOfType(.Value , withBlock: { (snapshot) in
            let type = snapshot.value as! String
            callback(privacy: type)
        })
    }
    
    private func cloneUserDetails(fbUser: FIRUser!, username: String, password: String, profileType: String, language: String ){
        
        let ref = References.UserRef.child(fbUser!.uid)
        
        let user = [ ReferenceLabels.Username: username,
                     ReferenceLabels.Password: password,
                     ReferenceLabels.PostCount: 0,
                     ReferenceLabels.PhotoIDS: [],
                     ReferenceLabels.UserTags: [],
                     ReferenceLabels.UserPosts: [],
                     ReferenceLabels.ProfileType: profileType,
                     ReferenceLabels.Language: language ]
        ref.updateChildValues(user as [NSObject : AnyObject])
    }
}