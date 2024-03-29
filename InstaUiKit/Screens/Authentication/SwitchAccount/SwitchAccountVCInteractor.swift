//
//  SwitchAccountVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation

protocol SwitchAccountVCInteractorProtocol {
    func fetchCoreDataUsers() async -> [CDUsersModel]
    func getUsers(cdUsers: [CDUsersModel], completion: @escaping ([UserModel]) -> Void)
}

class SwitchAccountVCInteractor {
    
}

extension SwitchAccountVCInteractor : SwitchAccountVCInteractorProtocol {
    
    func fetchCoreDataUsers() async -> [CDUsersModel] {
        do {
            let users = try await CDUserManager.shared.readUser()
            if let users = users {
                return users
            }
        } catch let error {
            print(error)
        }
        return []
    }
    
    func getUsers(cdUsers: [CDUsersModel], completion: @escaping ([UserModel]) -> Void) {
        var users = [UserModel]()
        let dispatchGroup = DispatchGroup()
        for i in cdUsers {
            print(i.uid)
            dispatchGroup.enter()
            FetchUserData.shared.fetchUserDataByUid(uid: i.uid) { result in
                switch result {
                case .success(let user):
                    if let user = user {
                        print(user)
                        users.append(user)
                    }
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(users)
        }
    }
    
    
}
