//
//  CDUsersManager.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import Foundation

final class CDUsersManager {
    static let shared = CDUsersManager()
    private init(){}
    
    func createUser(user : CDUsersModel , completion : @escaping (Bool) -> Void){
        let userContext = CDUsers(context: PersistantStorage.shared.persistentContainer.viewContext)
        userContext.id = user.id
        userContext.name = user.name
        userContext.userName = user.userName
        userContext.email = user.email
        userContext.password = user.password
        PersistantStorage.shared.saveContext()
        completion(true)
    }
    
    func readUser(completion : @escaping (Result<[CDUsersModel]? , Error >) -> Void) {
        var users = [CDUsersModel]()
        do {
            let data = try PersistantStorage.shared.persistentContainer.viewContext.fetch(CDUsers.fetchRequest())
            for i in data {
                if let id = i.id, let name = i.name, let userName = i.userName, let email = i.email, let password = i.password {
                    let user = CDUsersModel(id: id, name: name, userName: userName, email: email, password: password)
                    users.append(user)
                }
            }
            print(users)
            completion(.success(users))
        } catch let error {
            print(error)
            completion(.failure(error))
        }
    }
    
}
