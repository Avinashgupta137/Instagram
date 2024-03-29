//
//  SignUpVCPresenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation
import UIKit

protocol SignUpVCPresenterProtocol {
    func viewDidload()
    func signUp(emailTxtFld:String? , passwordTxtFld:String? , view : UIViewController)
}

class SignUpVCPresenter {
    
    weak var view : SignUpVCProtocol?
    var interactor : SignUpVCInteractorProtocol
    var router : SignUpVCRouterProtocol
    
    init(view:SignUpVCProtocol,interactor:SignUpVCInteractorProtocol,router:SignUpVCRouterProtocol){
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
}

extension SignUpVCPresenter : SignUpVCPresenterProtocol {
    
    func viewDidload() {
        
    }
    
    func signUp(emailTxtFld: String?, passwordTxtFld: String?, view: UIViewController) {
        guard let emailTxtFld = emailTxtFld, let passwordTxtFld = passwordTxtFld else {
            return
        }
        interactor.userSignUp(emailTxtFld: emailTxtFld, passwordTxtFld: passwordTxtFld) { result in
            switch result {
            case .success(let bool):
                print(bool)
                self.interactor.saveFCMTokenOfCurrentUser { _ in
                    self.interactor.saveCurrentUserToCoreData(email: emailTxtFld, password: passwordTxtFld, view: view) { bool in
                        if bool {
                            MessageLoader.shared.hideLoader()
                            self.router.goToMainTabVC()
                        }else{
                            MessageLoader.shared.hideLoader()
                            self.router.goToMainTabVC()
                        }
                    }
                }
            case .failure(let error):
                switch error {
                case .emailAndPasswordEmpty(let errorMessage):
                    print("Email and/or Password is empty: \(errorMessage)")
                    MessageLoader.shared.hideLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        Alert.shared.alertOk(title: "Warning!", message: "Please fill in all the required fields before proceeding.", presentingViewController: view){ _ in}
                    }
                case .signInError(let signInError):
                    print("Sign Up error: \(signInError.localizedDescription)")
                    MessageLoader.shared.hideLoader()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        Alert.shared.alertOk(title: "Error!", message: error.localizedDescription, presentingViewController: view){ _ in}
                    }
                }
            }
        }
    }
    
}
