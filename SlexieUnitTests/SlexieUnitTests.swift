//
//  SlexieUnitTests.swift
//  SlexieUnitTests
//
//  Created by Zafer Cavdar on 08/09/2016.
//  Copyright © 2016 Zafer Cavdar. All rights reserved.
//

import XCTest
@testable import Slexie

class SlexieUnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNewsFeedOperations(){
        
        var state = NewsFeedPostViewModel.State()
        
        let p1 = FeedPost(ownerUsername: "zctr", ownerID: "a1b2c3", id: "20160903SS161543UUa1b2c3", tags: ["nice","cool"], likers: ["a38km3pf","jasouu93"], likeCount: 2, isAlreadyLiked: false)
        let p2 = FeedPost(ownerUsername: "irencini", ownerID: "jasouu93", id: "20160903SS161543UUjasouu93", tags: ["man","cup"], likers: ["a38km3pf","a1b2c3"], likeCount: 2, isAlreadyLiked: false)
        let p3 = FeedPost(ownerUsername: "zctr", ownerID: "a1b2c3", id: "20160903SS161569UUa1b2c3", tags: ["breakfast","meal"], likers: ["a38km3pf","a1b2c3"], likeCount: 2, isAlreadyLiked: true)
        
        let noneChange = state.reloadPosts([])
        XCTAssertTrue(noneChange == .none)
        XCTAssertTrue(state.feedPosts == [])
        
        let reloadChange = state.reloadPosts([p1,p2])
        XCTAssertTrue(reloadChange == .posts(.reload))
        XCTAssertTrue(state.feedPosts == [p1, p2])
        
        let deletionChange = state.deletePost(0)
        XCTAssertTrue(deletionChange == .posts(.deletion(0)))
        XCTAssertTrue(state.feedPosts == [p2])
        
        let insertionChange = state.insertPost(p3)
        XCTAssertTrue(insertionChange == .posts(.insertion(1)))
        XCTAssertTrue(state.feedPosts == [p2, p3])
        
        let clearChange = state.clearPosts()
        XCTAssertTrue(clearChange == .posts(.reload))
        XCTAssertTrue(state.feedPosts == [])
        
        
    }
    
    func testSearchPostOperations(){
        var state = SearchPostViewModel.State()
        
        let p1 = FeedPost(ownerUsername: "zctr", ownerID: "a1b2c3", id: "20160903SS161543UUa1b2c3", tags: ["nice","cool"], likers: ["a38km3pf","jasouu93"], likeCount: 2, isAlreadyLiked: false)
        let p2 = FeedPost(ownerUsername: "irencini", ownerID: "jasouu93", id: "20160903SS161543UUjasouu93", tags: ["man","cup"], likers: ["a38km3pf","a1b2c3"], likeCount: 2, isAlreadyLiked: false)
        
        let reloadChange = state.reloadPosts([p1,p2])
        XCTAssertTrue(reloadChange == .posts(.reload))
        XCTAssertTrue(state.searchPosts == [p2, p1])
        
        let clearChange = state.cleanPosts()
        XCTAssertTrue(clearChange == .posts(.reload))
        XCTAssertTrue(state.searchPosts == [])
    }
    
    func testCameraViewModel(){
        var state = CameraViewModel.State()
        let tags = ["tag1","tag2","tag3"]
        let imageData = NSData()
        
        let reloadChange = state.reloadTags(tags)
        XCTAssertTrue(reloadChange == .tags(.reload))
        XCTAssertTrue(state.post.trustedTags == tags)
        
        let updatePhotoChange = state.updatePhoto(imageData)
        XCTAssertTrue(updatePhotoChange == .photo)
        XCTAssertTrue(state.post.imageData == imageData)
    }
    
    func testNotificationsViewModel(){
        var state = NotificationsViewModel.State()
        
        let n1 = Notification(ownerID: "a38km3pf", targetID: "20160903SS161543UUa1b2c3", doneByUserID: "jasouu93", doneByUsername: "zafercavdar", type: NotificationType.Liked)
        let n2 = Notification(ownerID: "a38km3pf", targetID: "20160903SS161543UUa1b2c3", doneByUserID: "ghjg8833", doneByUsername: "ellyfishbone", type: NotificationType.Liked)
        let n3 = Notification(ownerID: "a38km3pf", targetID: "20160903SS161543UUa1b2c3", doneByUserID: "llkfdklg999", doneByUsername: "ellyfishbone", type: NotificationType.Liked)
        
        let reloadChange = state.reloadNotifications([n1,n2,n3])
        XCTAssertTrue(reloadChange == .notifications(.reload))
        XCTAssertTrue(state.notifs == [n3,n2,n1])
    }
    
    func testProfilePostViewModel(){
        var state = ProfilePostViewModel.State()
        
        let p1 = FeedPost(ownerUsername: "zctr", ownerID: "a1b2c3", id: "20160903SS161543UUa1b2c3", tags: ["nice","cool"], likers: ["a38km3pf","jasouu93"], likeCount: 2, isAlreadyLiked: false)
        let p2 = FeedPost(ownerUsername: "irencini", ownerID: "jasouu93", id: "20160903SS161543UUjasouu93", tags: ["man","cup"], likers: ["a38km3pf","a1b2c3"], likeCount: 2, isAlreadyLiked: false)
        
        let reloadChange = state.reloadPosts([p1,p2])
        XCTAssertTrue(reloadChange == .posts(.reload))
        XCTAssertTrue(state.profilePosts == [p2, p1])
    }
    
    func testSinglePostViewModel(){
        var state = SinglePostViewModel.State()
        
        let p1 = FeedPost(ownerUsername: "zctr", ownerID: "a1b2c3", id: "20160903SS161543UUa1b2c3", tags: ["nice","cool"], likers: ["a38km3pf","jasouu93"], likeCount: 2, isAlreadyLiked: false)
        
        let reloadChange = state.reloadPost(p1)
        XCTAssertTrue(reloadChange == .post(.reload))
        XCTAssertTrue(state.post == p1)
        
    }
    
    func testNewsFeedLoading() {
        
        var state = NewsFeedPostViewModel.State()
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertTrue(state.loadingState.needsUpdate)
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 2)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 0)
        XCTAssertTrue(state.loadingState.needsUpdate)
    }
    
    func testNotificationLoading() {
        
        var state = NotificationsViewModel.State()
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertTrue(state.loadingState.needsUpdate)
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 2)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 0)
        XCTAssertTrue(state.loadingState.needsUpdate)
    }

    func testProfilePageLoading() {
        
        var state = ProfilePostViewModel.State()
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertTrue(state.loadingState.needsUpdate)
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 2)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 0)
        XCTAssertTrue(state.loadingState.needsUpdate)
    }
    
    func testChangePasswordLoading() {
        
        var state = ChangePasswordViewModel.State()
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertTrue(state.loadingState.needsUpdate)
        
        state.addActivity()
        XCTAssertTrue(state.loadingState.activityCount == 2)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 1)
        XCTAssertFalse(state.loadingState.needsUpdate)
        
        state.removeActivity()
        XCTAssertTrue(state.loadingState.activityCount == 0)
        XCTAssertTrue(state.loadingState.needsUpdate)
    }
    
}
