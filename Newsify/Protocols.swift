//
//  Protocols.swift
//  Slexie
//
//  Created by Zafer Cavdar on 08/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import Foundation
import UIKit

protocol DataTransferController{
    func uploadPhoto(image: NSData, tags: [String], callback: (error: NSError?, photoID: String, url: String) -> Void)
    func downloadPhoto(with photoID: String, completion callback: (UIImage?, NSError?) -> Void)
}

protocol UserDetailsController{
    func getAccountPrivacy(callback: (privacy: String) -> Void)
    func getAccountTags(completion: [String] -> Void)
    func getUsername(with uid: String, completion callback: (username: String) -> Void)
    func fetchUserLanguage(completion callback: (identifier: String) -> Void)
    
    func setAccountPrivacy(privacy: Privacy)
    func changePassword(oldPassword: String, newPassword: String, completion callback: (NSError?) -> Void)
    func changeLanguage(identifier: LanguageIdentifier, completion callback: () -> Void)
    func isPasswordCorrect(oldPassword: String, completion callback: (isCorrect: Bool) -> Void)
}

protocol NotificationController{
    func pushNotification(notification: Notification, completion callback: () -> Void)
    func removeNotification(notification: Notification, completion callback: () -> Void)
    func fetchNotifications(completion callback: [Notification] -> Void)
}

protocol LikeActionsController {
    func photoLiked(imageid: String, callback: (CallbackResult) -> Void)
    func photoUnliked(imageid: String, callback: (CallbackResult) -> Void)
    
}

protocol PostController{
    func getPhotosRelatedWith(tags: [String], count: Int, completion: [FeedPost] -> Void)
    func getProfilePosts(completion callback: [FeedPost] -> Void)
    func reportPost(id: String)
    func deletePost(with id: String)
    func getPost(with id: String, completion callback: (FeedPost) -> Void)
}

protocol DatabaseController: DataTransferController, UserDetailsController, NotificationController, LikeActionsController, PostController {
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