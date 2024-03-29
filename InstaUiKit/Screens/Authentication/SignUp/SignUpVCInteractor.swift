//
//  SignUpVCInteractor.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation
import FirebaseAuth
import UIKit

protocol SignUpVCInteractorProtocol {
    func userSignUp(emailTxtFld: String?, passwordTxtFld: String?, completionHandler: @escaping (Result< Bool,SignInError >) -> Void)
    func saveFCMTokenOfCurrentUser(completion:@escaping(Bool)->Void)
    func saveCurrentUserToCoreData(email:String?,password:String?,view : UIViewController,completion:@escaping(Bool) -> Void)
}

enum SignUpError : Error {
    case emailAndPasswordEmpty(error:String)
    case signUpError(error:Error)
}

class SignUpVCInteractor {
    
}

extension SignUpVCInteractor : SignUpVCInteractorProtocol {
    
    func userSignUp(emailTxtFld: String?, passwordTxtFld: String?, completionHandler: @escaping (Result< Bool,SignInError >) -> Void){
        MessageLoader.shared.showLoader(withText: "Signing Up..")
        guard let email = emailTxtFld, let password = passwordTxtFld, !email.isEmpty, !password.isEmpty else {
            completionHandler(.failure(SignInError.emailAndPasswordEmpty(error: "Email and Password is Empty!.")))
            return
        }
        self.signUp(email: email, password: password) { error in
            if let error = error {
                print(error.localizedDescription)
                completionHandler(.failure(SignInError.signInError(error: error)))
            } else {
                print("Sign Up Successfuly")
                if let uid = Auth.auth().currentUser?.uid {
                    print(uid)
                    UserDefaults.standard.removeObject(forKey: "CurrentUserId")
                    Data.shared.saveData(uid, key: "CurrentUserId") { value in
                        print(value)
                        let userDefaults = UserDefaults.standard
                        userDefaults.removeObject(forKey: "Name")
                        userDefaults.removeObject(forKey: "UserName")
                        userDefaults.removeObject(forKey: "Bio")
                        userDefaults.removeObject(forKey: "Gender")
                        userDefaults.removeObject(forKey: "CountryCode")
                        userDefaults.removeObject(forKey: "PhoneNumber")
                        userDefaults.removeObject(forKey: "ProfileUrl")
                        userDefaults.removeObject(forKey: "IsPrivate")
                        userDefaults.synchronize()
                        completionHandler(.success(true))
                    }
                }
            }
        }
    }
    
    private func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                // Handle sign-up error
                print("Sign-up error: \(error.localizedDescription)")
                completion(error)
                return
            }
            print("Sign-up successful with email: \(email)")
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
    
    func saveCurrentUserToCoreData(email:String?,password:String?,view : UIViewController,completion:@escaping(Bool) -> Void){
        guard let email = email , let password = password else {
            return
        }
        if let uid = FetchUserData.fetchUserInfoFromUserdefault(type: .uid){
            saveUserToCoreData(uid: uid, email: email, password: password, view: view) {
                completion(true)
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
    
}
