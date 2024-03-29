//
//  SignInVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

protocol SignInVCProtocol : class {
    
}

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    
    var isPasswordShow = false
    var presenter : SignInVCPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
        updateTxtFlds()
    }
    
    
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        presenter?.signIn(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text, view: self)
    }
    
    @IBAction func switchAccountsBtnPressed(_ sender: UIButton) {
        presenter?.showSwitchAccountVC()
    }
    
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        presenter?.goToSignUpVC()
    }
    
    
    @IBAction func passwordHideShowBtnPressed(_ sender: UIButton) {
        isPasswordShow.toggle()
        if isPasswordShow {
            let image = UIImage(systemName: "eye")
            passwordHideShowBtn.setImage(image, for: .normal)
        }else{
            let image = UIImage(systemName: "eye.slash")
            passwordHideShowBtn.setImage(image, for: .normal)
        }
        passwordTxtFld.isSecureTextEntry.toggle()
    }
    
    func updateTxtFlds(){
        emailTxtFld.placeholder = "Enter email"
        passwordTxtFld.placeholder = "Enter password"
    }
    
}

extension SignInVC : SignInVCProtocol {
    
}
