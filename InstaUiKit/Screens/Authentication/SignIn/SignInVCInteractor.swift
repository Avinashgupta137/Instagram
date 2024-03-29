//
//  SignInVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import FirebaseAuth
import UIKit

enum SignInError : Error {
    case emailAndPasswordEmpty(error:String)
    case signInError(error:Error)
}

protocol SignInVCInteractorProtocol {
    func login(emailTxtFld: String?, passwordTxtFld: String?, completionHandler: @escaping (Result< Bool,SignInError >) -> Void)
    func saveFCMTokenOfCurrentUser(completion:@escaping(Bool)->Void)
    func saveCurrentUserToCoreData(coreDataUsers:[CDUsersModel],email:String?,password:String?,view : UIViewController,completion:@escaping(Bool) -> Void)
    func fetchCoreDataUsers() async -> [CDUsersModel]
}

class SignInVCInteractor {
    
}

extension SignInVCInteractor : SignInVCInteractorProtocol {
    
    func login(emailTxtFld: String?, passwordTxtFld: String?, completionHandler: @escaping (Result< Bool,SignInError >) -> Void){
        MessageLoader.shared.showLoader(withText: "Signing In..")
        guard let email = emailTxtFld, let password = passwordTxtFld, !email.isEmpty, !password.isEmpty else {
            completionHandler(.failure(SignInError.emailAndPasswordEmpty(error: "Email and Password is Empty!.")))
            return
        }
        
        signIn(email: email, password: password) { error in
            if let error = error {
                print(error.localizedDescription)
                completionHandler(.failure(SignInError.signInError(error: error)))
            } else {
                print("Sign In Successfully")
                if let uid = Auth.auth().currentUser?.uid {
                    print(uid)
                    Data.shared.saveData(uid, key: "CurrentUserId") { value in
                        print(value)
                        EditProfileViewModel.shared.fetchUserProfileImageURL { result in
                            switch result {
                            case .success(let url):
                                if let urlString = url?.absoluteString {
                                    Data.shared.saveData(urlString, key: "ProfileUrl") { (value: Bool) in
                                    }
                                }
                            case.failure(let error):
                                print(error)
                            }
                        }
                        
                        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
                            switch result {
                            case .success(let data):
                                if let data = data {
                                    print(data)
                                    Data.shared.saveData(data.name, key: "Name"){ _ in}
                                    Data.shared.saveData(data.username, key: "UserName") { _ in}
                                    Data.shared.saveData(data.bio, key: "Bio") { _ in}
                                    Data.shared.saveData(data.gender, key: "Gender") { _ in}
                                    Data.shared.saveData(data.countryCode, key: "CountryCode") { _ in}
                                    Data.shared.saveData(data.phoneNumber, key: "PhoneNumber") { _ in}
                                    Data.shared.saveData(data.isPrivate, key: "IsPrivate") { _ in}
                                }
                                completionHandler(.success(true))
                            case.failure(let error):
                                print(error)
                                completionHandler(.success(true))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                // Handle sign-in error
                print("Sign-in error: \(error.localizedDescription)")
                completion(error)
                return
            }
            print("Sign-in successful with email: \(email)")
            completion(nil)
        }
    }
    
    func saveFCMTokenOfCurrentUser(completion:@escaping(Bool)->Void){
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            FetchUserData.shared.getFCMToken { fcmToken in
                if let fcmToken = fcmToken {
                    StoreUserData.shared.saveUsersFMCTokenAndUidToFirebase(uid: uid, fcmToken: fcmToken) { result in
                        switch result {
                        case .success(let success):
                            completion(true)
                        case .failure(let failure):
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    func saveCurrentUserToCoreData(coreDataUsers:[CDUsersModel],email:String?,password:String?,view : UIViewController,completion:@escaping(Bool) -> Void){
        guard let email = email , let password = password else {
            return
        }
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            if coreDataUsers.contains(where: { $0.uid == uid }) {
                completion(false)
            } else {
                saveUserToCoreData(uid: uid, email: email, password: password, view: view) {
                    completion(true)
                }
            }
        }
    }
    
    
    private func saveUserToCoreData(uid:String , email:String? , password : String? ,view : UIViewController, completion : @escaping ()->Void){
        DispatchQueue.main.async {
            MessageLoader.shared.hideLoader()
            Alert.shared.alertYesNo(title: "Save User!", message: "Do you want to save user?.", presentingViewController: view) { _ in
                print("Yes")
                if let email = email, let password = password {
                    CDUserManager.shared.createUser(user: CDUsersModel(id: UUID(), email: email, password: password, uid: uid)) { _ in
                        completion()
                    }
                }
            } noHandler: { _ in
                print("No")
                completion()
            }
        }
    }
    
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
    
    
}
