//
//  PostAllDataModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 08/12/23.
//

import Foundation
import FirebaseFirestore

struct PostAllDataModel {
    var postImageURLs: [String]?
    var caption: String?
    var location: String?
    var name: String?
    var uid: String?
    var profileImageUrl: String?
    var postDocumentID: String?
    var likedBy: [String]?
    var likesCount: Int?
    var comments: [[String: Any]]?
    var username: String?
    var timestamp: Timestamp?

    init(postImageURLs: [String], caption: String, location: String, name: String, uid: String, profileImageUrl: String, postDocumentID: String, likedBy: [String], likesCount: Int, comments: [[String: Any]], username: String, timestamp: Timestamp) {
        self.postImageURLs = postImageURLs
        self.caption = caption
        self.location = location
        self.name = name
        self.uid = uid
        self.profileImageUrl = profileImageUrl
        self.postDocumentID = postDocumentID
        self.likedBy = likedBy
        self.likesCount = likesCount
        self.comments = comments
        self.username = username
        self.timestamp = timestamp
    }
}
