//
//  SignUpVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SwiftUI
import FirebaseAuth


protocol SignUpVCProtocol : class {
    
}

class SignUpVC: UIViewController {
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var passwordHideShowBtn: UIButton!
    
    var isPasswordShow = false
    var presenter : SignUpVCPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
        updateTxtFlds()
    }
    
    @IBAction func forgetPasswordBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        presenter?.signUp(emailTxtFld: emailTxtFld.text, passwordTxtFld: passwordTxtFld.text, view: self)
    }
    
    
    @IBAction func logInWithFaceBookBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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

extension SignUpVC : SignUpVCProtocol {
    
}
