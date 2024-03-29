//
//  CDUserManager.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import Foundation
import CoreData

protocol CDUserManagerProtocol{
    func createUser(user : CDUsersModel , completion : @escaping (Bool) -> Void)
    func readUser() async throws -> [CDUsersModel]?
    func deleteUser(withId id: UUID, completion: @escaping (Bool) -> Void)
}

class CDUserManager {
    static let shared = CDUserManager()
    private init(){}
}

extension CDUserManager : CDUserManagerProtocol {
    
    func createUser(user : CDUsersModel , completion : @escaping (Bool) -> Void){
        let userContext = CDUsers(context: PersistantStorage.shared.persistentContainer.viewContext)
        userContext.id = user.id
        userContext.email = user.email
        userContext.password = user.password
        userContext.uid = user.uid
        PersistantStorage.shared.saveContext()
        completion(true)
    }
    
    func readUser() async throws -> [CDUsersModel]? {
        var users = [CDUsersModel]()
        do {
            let data = try PersistantStorage.shared.persistentContainer.viewContext.fetch(CDUsers.fetchRequest())
            for i in data {
                if let id = i.id, let email = i.email, let password = i.password , let uid = i.uid {
                    let user = CDUsersModel(id: id, email: email, password: password, uid: uid)
                    users.append(user)
                }
            }
            print(users)
            return users
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func deleteUser(withId id: UUID, completion: @escaping (Bool) -> Void) {
        do {
            let fetchRequest: NSFetchRequest<CDUsers> = CDUsers.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            let context = PersistantStorage.shared.persistentContainer.viewContext
            if let userToDelete = try context.fetch(fetchRequest).first {
                context.delete(userToDelete)
                PersistantStorage.shared.saveContext()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print(error)
            completion(false)
        }
    }
}
