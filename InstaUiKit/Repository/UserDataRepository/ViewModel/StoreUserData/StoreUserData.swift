//
//  UserInfo.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/11/23.
//

import Foundation
import FirebaseFirestore

protocol StoreUserDataProtocol {
    func saveUsersFMCTokenAndUidToFirebase(uid: String, fcmToken: String, completion: @escaping (Result<Void, Error>) -> Void)
    func saveFollowersToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func saveFollowingsToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func removeFollowerFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func removeFollowingFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func saveFollowersRequestToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func saveFollowingsRequestToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func removeFollowerRequestFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func removeFollowingRequestFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void)
    func saveUsersChatList(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func removeUserFromChatUserListOfSender(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func saveUsersChatNotifications(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func removeUsersChatNotifications(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class StoreUserData {
    static let shared = StoreUserData()
    private init(){}
}

extension StoreUserData : StoreUserDataProtocol {
    // MARK: - Save Users FMCToken And Uid
    
    func saveUsersFMCTokenAndUidToFirebase(uid: String, fcmToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        // Create a dictionary with both the uid and fcmToken
        let data: [String: Any] = ["uid": uid, "fcmToken": fcmToken]
        // Set the document with the combined data
        userRef.setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Save User's Followers
    
    
    func saveFollowersToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(toFollowsUid)
        // Update the document with the followings UID
        userRef.setData(["followers": FieldValue.arrayUnion([whoFollowingsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Save User's Followings
    
    func saveFollowingsToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(whoFollowingsUid)
        // Update the document with the followings UID
        userRef.setData(["followings": FieldValue.arrayUnion([toFollowsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Remove User from Followers
    
    func removeFollowerFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(toFollowsUid)
        // Update the document by removing the follower's UID
        userRef.setData(["followers": FieldValue.arrayRemove([whoFollowingsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Remove User from Followings
    
    func removeFollowingFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(whoFollowingsUid)
        // Update the document by removing the following's UID
        userRef.setData(["followings": FieldValue.arrayRemove([toFollowsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
    // MARK: - Save User's FollowersRequest
    
    
    func saveFollowersRequestToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(toFollowsUid)
        // Update the document with the followings UID
        userRef.setData(["followersRequest": FieldValue.arrayUnion([whoFollowingsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Save User's FollowingsRequest
    
    func saveFollowingsRequestToFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(whoFollowingsUid)
        // Update the document with the followings UID
        userRef.setData(["followingsRequest": FieldValue.arrayUnion([toFollowsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Remove User from FollowersRequest
    
    func removeFollowerRequestFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(toFollowsUid)
        // Update the document by removing the follower's UID
        userRef.setData(["followersRequest": FieldValue.arrayRemove([whoFollowingsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Remove User from FollowingsRequest
    
    func removeFollowingRequestFromFirebaseOfUser(toFollowsUid: String, whoFollowingsUid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(whoFollowingsUid)
        // Update the document by removing the following's UID
        userRef.setData(["followingsRequest": FieldValue.arrayRemove([toFollowsUid])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Save UsersChatList
    
    func saveUsersChatList(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRefSenderId = db.collection("users").document(senderId)
        let userRefReceiverId = db.collection("users").document(receiverId)
        
        let updateUsersChatList: (DocumentReference, String) -> Void = { userRef, uid in
            userRef.setData(["usersChatList": FieldValue.arrayUnion([uid])], merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        
        updateUsersChatList(userRefSenderId, receiverId)
        updateUsersChatList(userRefReceiverId, senderId)
    }
    
    // MARK: - Remove User from chatUserListOfSender
    
    func removeUserFromChatUserListOfSender(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(senderId)
        // Update the document by removing the follower's UID
        userRef.setData(["usersChatList": FieldValue.arrayRemove([receiverId])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Save User's chatNotifications
    
    func saveUsersChatNotifications(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(receiverId)
        // Update the document with the followings UID
        userRef.setData(["usersChatNotification": FieldValue.arrayUnion([senderId])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Remove User's chatNotifications
    
    func removeUsersChatNotifications(senderId: String, receiverId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(senderId)
        // Update the document by removing the follower's UID
        userRef.setData(["usersChatNotification": FieldValue.arrayRemove([receiverId])], merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
