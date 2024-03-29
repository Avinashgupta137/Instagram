//
//  DirectMsgVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import Firebase

protocol DirectMsgVCInteractorProtocol {
    func fetchChatUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void )
    func observeLastTextMessage(currentUserId: String?, receiverUserId: String?, completion: @escaping (String?, String?) -> Void)
    func removeUserFromChatlistOfSender(receiverId : String? , completion : @escaping (Bool) -> Void)
    func fetchUniqueUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void)
    func fetchAllChatUsersAndCurrentUser(completion:@escaping(_ chatUsers:[UserModel] , _ currentUser : UserModel) -> ())
    func fetchAllUniqueUsers()
    var chatUsers : [UserModel]? { get set }
    var allUniqueUsersArray: [UserModel] { get set }
    var currentUser : UserModel? { get set }
}

class DirectMsgVCInteractor {
    var chatUsers : [UserModel]?
    var allUniqueUsersArray = [UserModel]()
    var currentUser : UserModel?
    var observeChat = [[String:String]]()
    let dispatchGroup = DispatchGroup()
}

extension DirectMsgVCInteractor : DirectMsgVCInteractorProtocol {
    
    func fetchAllUniqueUsers() {
        self.fetchUniqueUsers{ result in
            switch result {
            case.success(let data):
                if let data = data {
                    self.allUniqueUsersArray = data
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func fetchAllChatUsersAndCurrentUser(completion:@escaping(_ chatUsers:[UserModel] , _ currentUser : UserModel) -> ()) {
        self.fetchChatUsers { result in
            switch result {
            case .success(let data):
                if let data = data {
                    print(data)
                    self.chatUsers = data
                    FetchUserData.shared.fetchCurrentUserFromFirebase { result in
                        switch result {
                        case .success(let user):
                            if let user = user {
                                self.currentUser = user
                                if let currentUser = self.currentUser, let chatUsers = self.chatUsers {
                                    completion(chatUsers, currentUser)
                                }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func fetchChatUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void ) {
        var chatUsers = [UserModel]()
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let data):
                if let data = data , let chatUserList = data.usersChatList {
                    for uid in chatUserList {
                        self.dispatchGroup.enter()
                        FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                            self.dispatchGroup.leave()
                            switch result {
                            case.success(let userData):
                                if let userData = userData {
                                    chatUsers.append(userData)
                                }
                            case.failure(let error):
                                print(error)
                            }
                        }
                    }
                    self.dispatchGroup.notify(queue: .main) {
                        completion(.success(chatUsers))
                    }
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func fetchUniqueUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void){
        var allUniqueUsersArray = [UserModel]()
        FetchUserData.shared.fetchCurrentUserFromFirebase { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                guard let user = user, let following = user.followings else {return}
                FetchUserData.shared.fetchUniqueUsersFromFirebase { result in
                    switch result {
                    case .success(let data):
                        let uniqueUserUids = Set(following)
                        let newUsers = data.filter { user in
                            guard let userUid = user.uid else { return false }
                            return uniqueUserUids.contains(userUid) && !allUniqueUsersArray.contains(where: { $0.uid == user.uid })
                        }
                        allUniqueUsersArray.append(contentsOf: newUsers)
                        completion(.success(allUniqueUsersArray))
                    case .failure(let error):
                        print(error)
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    
    func removeUserFromChatlistOfSender(receiverId : String? , completion : @escaping (Bool) -> Void ){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let data):
                if let data = data , let senderId = data.uid , let receiverId = receiverId {
                    StoreUserData.shared.removeUserFromChatUserListOfSender(senderId: senderId, receiverId: receiverId) { result in
                        switch result {
                        case.success():
                            completion(true)
                        case.failure(let error):
                            completion(false)
                        }
                    }
                }
            case.failure(let error):
                print(error)
                completion(false)
            }
        }
    }
    
    func observeLastTextMessage(currentUserId: String?, receiverUserId: String?, completion: @escaping (String?, String?) -> Void) {
        guard let currentUserId = currentUserId, let receiverUserId = receiverUserId else {
            print("Error: currentUserId or receiverUserId is nil")
            return
        }
        
        let chatPath = currentUserId < receiverUserId ? "\(currentUserId)_\(receiverUserId)" : "\(receiverUserId)_\(currentUserId)"
        
        let textMessagesRef = Database.database().reference().child("messages").child(chatPath)
        
        textMessagesRef.queryLimited(toLast: 1).observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let senderId = messageData["senderId"] as? String,
                  let kindString = messageData["kind"] as? String,
                  kindString == "text",
                  let text = messageData["text"] as? String else {
                      return
                  }
            
            DispatchQueue.main.async {
                completion(text, senderId)
            }
        }
    }
    
    
    func chatPath(senderId: String, receiverId: String) -> String {
        return senderId < receiverId ? "\(senderId)_\(receiverId)" : "\(receiverId)_\(senderId)"
    }
    
    
}
