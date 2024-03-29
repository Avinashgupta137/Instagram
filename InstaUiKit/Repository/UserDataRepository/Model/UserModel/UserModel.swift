//
//  UserModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import Foundation

struct UserModel {
    var uid: String?
    var bio: String?
    var fcmToken: String?
    var phoneNumber: String?
    var countryCode: String?
    var name: String?
    var imageUrl: String?
    var gender: String?
    var username: String?
    var followers: [String]?
    var followings:[String]?
    var isPrivate : String?
    var followingsRequest : [String]?
    var followersRequest : [String]?
    var usersChatList : [String]?
    var usersChatNotification : [String]?
    var usersStories : [[String:String]]?
    
    init(uid: String, bio: String, fcmToken: String, phoneNumber: String, countryCode: String, name: String, imageUrl: String, gender: String, username: String,followers: [String],followings:[String] ,isPrivate : String , followingsRequest : [String]? , followersRequest : [String]? , usersChatList : [String]? , usersChatNotification : [String]? , usersStories : [[String:String]]?) {
        self.uid = uid
        self.bio = bio
        self.fcmToken = fcmToken
        self.phoneNumber = phoneNumber
        self.countryCode = countryCode
        self.name = name
        self.imageUrl = imageUrl
        self.gender = gender
        self.username = username
        self.followers = followers
        self.followings = followings
        self.isPrivate = isPrivate
        self.followingsRequest = followingsRequest
        self.followersRequest = followersRequest
        self.usersChatList = usersChatList
        self.usersChatNotification = usersChatNotification
        self.usersStories = usersStories
    }
    
}

