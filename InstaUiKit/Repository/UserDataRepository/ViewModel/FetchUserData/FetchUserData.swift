//
//  FetchUserInfo.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import Foundation
import FirebaseFirestore
import Firebase

protocol FetchUserDataProtocol {
    func fetchUniqueUsersFromFirebase(completionHandler: @escaping (Result<[UserModel], Error>) -> Void)
    func fetchCurrentUserFromFirebase(completionHandler: @escaping (Result<UserModel?, Error>) -> Void)
    func fetchUserDataByUid(uid: String, completionHandler: @escaping (Result<UserModel?, Error>) -> Void)
    func getFCMToken(completion: @escaping (String?) -> Void)
}


class FetchUserData {
    static let shared = FetchUserData()
    private init() {}
}

extension FetchUserData : FetchUserDataProtocol {
    // MARK: - Fetch Users Info from Userdefault
    
    enum UserInfoFromUserdefault: String {
        case uid = "CurrentUserId"
        case name = "Name"
        case userName = "UserName"
        case bio = "Bio"
        case gender = "Gender"
        case countryCode = "CountryCode"
        case phoneNumber = "PhoneNumber"
        case profileUrl = "ProfileUrl"
        case isPrivate = "IsPrivate"
    }
    
    static func fetchUserInfoFromUserdefault(type: UserInfoFromUserdefault) -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var result: String?
        Data.shared.getData(key: type.rawValue) { (dataResult: Result<String?, Error>) in
            switch dataResult {
            case .success(let data):
                result = data
            case .failure(let error):
                print(error)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    // MARK: - Fetch Unique Users From Firebase
    
    func fetchUniqueUsersFromFirebase(completionHandler: @escaping (Result<[UserModel], Error>) -> Void) {
        if let currentUid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            let db = Firestore.firestore()
            db.collection("users")
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching users: \(error.localizedDescription)")
                        completionHandler(.failure(error))
                    } else {
                        var users: [UserModel] = []
                        for document in querySnapshot!.documents {
                            print("Fetched user document: \(document.data())")
                            let imageURL = document["imageUrl"] as? String
                            let bio = document["bio"] as? String
                            let countryCode = document["countryCode"] as? String
                            let fcmToken = document["fcmToken"] as? String
                            let gender = document["gender"] as? String
                            let name = document["name"] as? String
                            let phoneNumber = document["phoneNumber"] as? String
                            let uid = document["uid"] as? String
                            let username = document["username"] as? String
                            let followers = document["followers"] as? [String]
                            let followings = document["followings"] as? [String]
                            let isPrivate = document["isPrivate"] as? String
                            let followingsRequest = document["followingsRequest"] as? [String]
                            let followersRequest = document["followersRequest"] as? [String]
                            let usersChatList = document["usersChatList"] as? [String]
                            let usersChatNotification = document["usersChatNotification"] as? [String]
                            let usersStories = document["usersStories"] as? [[String:String]]
                            if uid != currentUid { // Check if the uid is not the current user's uid
                                let user = UserModel(uid: uid ?? "", bio: bio ?? "", fcmToken: fcmToken ?? "", phoneNumber: phoneNumber ?? "", countryCode: countryCode ?? "", name: name ?? "", imageUrl: imageURL ?? "", gender: gender ?? "", username: username ?? "", followers : followers ?? [] , followings: followings ?? [] , isPrivate:isPrivate ?? "" , followingsRequest : followingsRequest ?? [] , followersRequest : followersRequest ?? [] , usersChatList : usersChatList ?? [] , usersChatNotification :usersChatNotification ?? [] , usersStories : usersStories ?? [])
                                users.append(user)
                                print(users)
                            }
                            
                        }
                        DispatchQueue.main.async {
                            completionHandler(.success(users))
                        }
                    }
                }
        }
    }
    
    // MARK: - Fetch CurrentUser From Firebase
    
    func fetchCurrentUserFromFirebase(completionHandler: @escaping (Result<UserModel?, Error>) -> Void) {
        if let currentUid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            let db = Firestore.firestore()
            db.collection("users").document(currentUid).getDocument { (document, error) in
                if let error = error {
                    print("Error fetching current user: \(error.localizedDescription)")
                    completionHandler(.failure(error))
                } else if let document = document, document.exists {
                    print("Fetched current user document: \(document.data())")
                    let imageURL = document["imageUrl"] as? String
                    let bio = document["bio"] as? String
                    let countryCode = document["countryCode"] as? String
                    let fcmToken = document["fcmToken"] as? String
                    let gender = document["gender"] as? String
                    let name = document["name"] as? String
                    let phoneNumber = document["phoneNumber"] as? String
                    let uid = document["uid"] as? String
                    let username = document["username"] as? String
                    let followers = document["followers"] as? [String]
                    let followings = document["followings"] as? [String]
                    let isPrivate = document["isPrivate"] as? String
                    let followingsRequest = document["followingsRequest"] as? [String]
                    let followersRequest = document["followersRequest"] as? [String]
                    let usersChatList = document["usersChatList"] as? [String]
                    let usersChatNotification = document["usersChatNotification"] as? [String]
                    let usersStories = document["usersStories"] as? [[String:String]]
                    let user = UserModel(uid: uid ?? "", bio: bio ?? "", fcmToken: fcmToken ?? "", phoneNumber: phoneNumber ?? "", countryCode: countryCode ?? "", name: name ?? "", imageUrl: imageURL ?? "", gender: gender ?? "", username: username ?? "", followers : followers ?? [] , followings: followings ?? [] , isPrivate : isPrivate ?? "" ,followingsRequest : followingsRequest ?? [] , followersRequest : followersRequest ?? [] , usersChatList : usersChatList ?? [] , usersChatNotification : usersChatNotification ?? [] , usersStories : usersStories ?? [])
                    DispatchQueue.main.async {
                        completionHandler(.success(user))
                    }
                } else {
                    // User document not found
                    DispatchQueue.main.async {
                        completionHandler(.success(nil))
                    }
                }
            }
        }
    }
    
    // MARK: - Fetch User From Firebase By Uid
    
    func fetchUserDataByUid(uid: String, completionHandler: @escaping (Result<UserModel?, Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user with uid \(uid): \(error.localizedDescription)")
                completionHandler(.failure(error))
            } else if let document = document, document.exists {
                print("Fetched user document with uid \(uid): \(document.data())")
                let imageURL = document["imageUrl"] as? String
                let bio = document["bio"] as? String
                let countryCode = document["countryCode"] as? String
                let fcmToken = document["fcmToken"] as? String
                let gender = document["gender"] as? String
                let name = document["name"] as? String
                let phoneNumber = document["phoneNumber"] as? String
                let userUid = document["uid"] as? String
                let username = document["username"] as? String
                let followers = document["followers"] as? [String]
                let followings = document["followings"] as? [String]
                let isPrivate = document["isPrivate"] as? String
                let followingsRequest = document["followingsRequest"] as? [String]
                let followersRequest = document["followersRequest"] as? [String]
                let usersChatList = document["usersChatList"] as? [String]
                let usersChatNotification = document["usersChatNotification"] as? [String]
                let usersStories = document["usersStories"] as? [[String:String]]
                let user = UserModel(uid: userUid ?? "", bio: bio ?? "", fcmToken: fcmToken ?? "", phoneNumber: phoneNumber ?? "", countryCode: countryCode ?? "", name: name ?? "", imageUrl: imageURL ?? "", gender: gender ?? "", username: username ?? "", followers: followers ?? [], followings: followings ?? [] , isPrivate : isPrivate ?? "" ,followingsRequest : followingsRequest ?? [] , followersRequest : followersRequest ?? [] , usersChatList : usersChatList ?? [] , usersChatNotification : usersChatNotification ?? [] , usersStories : usersStories ?? [])
                DispatchQueue.main.async {
                    completionHandler(.success(user))
                }
            } else {
                // User document not found
                DispatchQueue.main.async {
                    completionHandler(.success(nil))
                }
            }
        }
    }
    
    // MARK: - Fetch FMCToken
    
    func getFCMToken(completion: @escaping (String?) -> Void) {
        // Check if Firebase is configured
        guard let _ = FirebaseApp.app() else {
            completion(nil)
            return
        }
        // Get the FCM token
        if let token = Messaging.messaging().fcmToken {
            completion(token)
        } else {
            // FCM token not available, try to refresh it
            Messaging.messaging().token { token, error in
                if let token = token {
                    completion(token)
                } else {
                    completion(nil)
                    print("Error fetching FCM token: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
