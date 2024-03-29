//
//  ProfileViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 07/08/23.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


class ProfileViewModel {
    static let shared = ProfileViewModel()
    var userModel : ProfileModel?
    init() {
        
    }
    
    func saveUserToFirebase(uid: String, name: String?, username: String?, bio: String?, phoneNumber: String?, gender: String?,countryCode : String?,isPrivate:String?,completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        let dispatchGroup = DispatchGroup()
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let document = document, !document.exists {
                // Document doesn't exist, create it first
                userRef.setData([:]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    updateUserData()
                }
            } else {
                updateUserData()
            }
        }
        
        
        func updateUserData() {
            if let name = name {
                dispatchGroup.enter()
                userRef.updateData(["name": name]) { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    dispatchGroup.leave()
                }
            }
            
            if let username = username {
                dispatchGroup.enter()
                userRef.updateData(["username": username]) { error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    dispatchGroup.leave()
                }
                
                if let bio = bio {
                    dispatchGroup.enter()
                    userRef.updateData(["bio": bio]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let phoneNumber = phoneNumber {
                    dispatchGroup.enter()
                    userRef.updateData(["phoneNumber": phoneNumber]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let countryCode = countryCode {
                    dispatchGroup.enter()
                    userRef.updateData(["countryCode": countryCode]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let gender = gender {
                    dispatchGroup.enter()
                    userRef.updateData(["gender": gender]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                if let isPrivate = isPrivate {
                    dispatchGroup.enter()
                    userRef.updateData(["isPrivate": isPrivate]) { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(()))
                }
            }
            
        }
        
    }
     
}
