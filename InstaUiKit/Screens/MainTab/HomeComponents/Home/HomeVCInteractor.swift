//
//  HomeVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol HomeVCInteractorProtocol {
    func fetchAllPostsOfFollowings(completion: @escaping (Result<[PostAllDataModel]?, Error>) -> Void)
    func fetchFollowingUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void)
    func fetchAllNotifications(completion:@escaping (Result<Int , Error>) -> Void)
    func fetchUserChatNotificationCount(completion:@escaping (Result<Int?,Error>) -> Void)
}

class HomeVCInteractor {
    
}

extension HomeVCInteractor : HomeVCInteractorProtocol {
    
    func fetchAllPostsOfFollowings(completion: @escaping (Result<[PostAllDataModel]?, Error>) -> Void) {
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let user):
                if let user = user, let followings = user.followings , let currentUserUid = user.uid {
                    var posts = [PostAllDataModel]()
                    PostViewModel.shared.fetchAllPosts { result in
                        switch result {
                        case .success(let fetchedPosts):
                            for post in fetchedPosts {
                                if let uid = post.uid {
                                    if followings.contains(uid) || currentUserUid == (uid) {
                                        posts.append(post)
                                    }
                                }
                            }
                            completion(.success(posts))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func fetchFollowingUsers(completion:@escaping (Result<[UserModel]?,Error>) -> Void){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user, let followings = user.followings {
                    var users = [UserModel]()
                    FetchUserData.shared.fetchUniqueUsersFromFirebase { result in
                        switch result {
                        case .success(let fetchedUsers):
                            for user in fetchedUsers {
                                if let uid = user.uid {
                                    if followings.contains(uid){
                                        users.append(user)
                                    }
                                }
                            }
                            completion(.success(users))
                        case .failure(let error):
                            print(error)
                            completion(.failure(error))
                        }
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func fetchAllNotifications(completion:@escaping (Result<Int , Error>) -> Void){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    completion(.success(user.followersRequest?.count ?? 0))
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func fetchUserChatNotificationCount(completion:@escaping (Result<Int?,Error>) -> Void){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user , let notification = user.usersChatNotification {
                    completion(.success(notification.count))
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
}
