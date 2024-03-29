//
//  NotificationVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation

protocol NotificationVCInteractorProtocol {
    func fetchCurrentUser(completion:@escaping(Result<UserModel,Error>)->())
    func removeFollowRequest(toFollowsUid:String?,whoFollowingsUid:String?,completion:@escaping (Bool) -> Void)
    func acceptFollowRequest(toFollowsUid:String?,whoFollowingsUid:String? , completion:@escaping (Bool) -> Void )
}

class NotificationVCInteractor {
    
}

extension NotificationVCInteractor : NotificationVCInteractorProtocol {
    
    func fetchCurrentUser(completion:@escaping(Result<UserModel,Error>)->()){
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case.success(let user):
                if let user = user {
                    completion(.success(user))
                }
            case.failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func removeFollowRequest(toFollowsUid:String?,whoFollowingsUid:String?,completion:@escaping (Bool) -> Void){
        if let toFollowsUid = toFollowsUid , let whoFollowingsUid = whoFollowingsUid {
            StoreUserData.shared.removeFollowerRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { result in
                switch result {
                case.success(let success):
                    StoreUserData.shared.removeFollowingRequestFromFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { _ in
                        completion(true)
                    }
                case.failure(let error):
                    print(error)
                    completion(false)
                }
            }
        }
    }
    
    func acceptFollowRequest(toFollowsUid:String?,whoFollowingsUid:String? , completion:@escaping (Bool) -> Void ){
        if let toFollowsUid = toFollowsUid , let whoFollowingsUid = whoFollowingsUid {
            StoreUserData.shared.saveFollowersToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: whoFollowingsUid) { _ in
                completion(true)
            }
        }
    }
    
}
