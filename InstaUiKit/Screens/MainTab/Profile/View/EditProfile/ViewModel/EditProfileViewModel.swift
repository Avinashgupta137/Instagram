//
//  EditProfileViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 07/08/23.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import UIKit

class EditProfileViewModel {
    static let shared = EditProfileViewModel()
    var eventHandler: ((_ event : Event) -> Void)?
    var userModel: ProfileModel?
    
    // Function which save Userinfo to firebase
    
    func saveDataToFirebase(name:String?,username:String?,bio:String?,countryCode:String?,phoneNumber:String?,gender:String? , isPrivate : String?, completionHandler:@escaping(Bool) -> Void){
        guard let name = name , let username = username , let bio = bio, let countryCode = countryCode , let phoneNumber = phoneNumber , let gender = gender , let isPrivate = isPrivate else { return }
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            ProfileViewModel.shared.saveUserToFirebase(uid: uid, name: name, username: username, bio: bio, phoneNumber: phoneNumber, gender: gender, countryCode: countryCode, isPrivate: isPrivate){ result in
                switch result {
                case .success():
                    print("User data saved successfully in database.")
                    
                    FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                        switch result {
                        case .success(let data):
                            if let data = data {
                                self.saveUserInfo(data: data){ value in
                                    print(value)
                                    completionHandler(true)
                                }
                            }
                        case .failure(let failure):
                            print(failure)
                            completionHandler(false)
                        }
                    }
                    
                case .failure(let error):
                    print("Error saving user data: \(error)")
                    completionHandler(false)
                }
            }
        }
    }
    
    // Function which save Userimage to firebase
    
    func saveUserImageToFirebase(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            let profileImagesRef = storageRef.child("profile_images/\(uid)")
            let imageFileName = "\(UUID().uuidString).jpg"
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let imageRef = profileImagesRef.child(imageFileName)
                let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        imageRef.downloadURL { url, error in
                            if let downloadURL = url {
                                completion(.success(downloadURL))
                                print(url)
                            } else {
                                if let error = error {
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
                uploadTask.observe(.progress) { snapshot in
                }
            }
        }
    }
    
    // Function which save Userinfo locally in userdefault
    
    func saveUserInfo(data:UserModel? ,completionHandler:@escaping(Bool) -> Void){
        if let data = data {
            Data.shared.saveData(data.name, key: "Name"){ _ in}
            Data.shared.saveData(data.username, key: "UserName") { _ in}
            Data.shared.saveData(data.bio, key: "Bio") { _ in}
            Data.shared.saveData(data.gender, key: "Gender") { _ in}
            Data.shared.saveData(data.countryCode, key: "CountryCode") { _ in}
            Data.shared.saveData(data.phoneNumber, key: "PhoneNumber") { _ in}
            Data.shared.saveData(data.isPrivate, key: "IsPrivate") { _ in}
            completionHandler(true)
        }else{
            completionHandler(false)
        }
    }
    
    // Function which fetch URL of Profile Image of currentUser
    
    func fetchUserProfileImageURL(completion: @escaping (Result<URL?, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            let profileImagesRef = storageRef.child("profile_images/\(uid)")
            profileImagesRef.listAll { (result, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let firstItem = result?.items.first {
                        firstItem.downloadURL { (url, error) in
                            if let downloadURL = url {
                                completion(.success(downloadURL))
                            } else {
                                if let error = error {
                                    completion(.failure(error))
                                }
                            }
                        }
                    } else {
                        completion(.success(nil))
                    }
                }
            }
        }
    }
    
    // Function which fetch Userinfo from firebase
    
    func fetchUserProfileImageURLWithUid( uid :String?,completion: @escaping (Result<URL?, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if let uid = uid {
            let profileImagesRef = storageRef.child("profile_images/\(uid)")
            profileImagesRef.listAll { (result, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let firstItem = result?.items.first {
                        firstItem.downloadURL { (url, error) in
                            if let downloadURL = url {
                                completion(.success(downloadURL))
                            } else {
                                if let error = error {
                                    completion(.failure(error))
                                }
                            }
                        }
                    } else {
                        completion(.success(nil))
                    }
                }
            }
        }
    }
    
    
    func saveUserProfileImageToFirebaseDatabase(uid: String, imageUrl: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        // Check if the document exists
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let document = document, document.exists {
                if let imageUrl = imageUrl {
                    userRef.updateData(["imageUrl": imageUrl]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else {
                }
            } else {
                // Handle the case where the user document doesn't exist
                completion(.failure(error as! Error))
            }
        }
    }
    
}

extension EditProfileViewModel {
    enum Event {
        case loading
        case stopLoading
        case loaded
        case error(Error?)
    }
}
