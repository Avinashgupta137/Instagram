//
//  DirectMsgVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

final class DirectMsgVCBuilder {
    
    static var backButtonPressedClosure : (()->())?
    static var addChatBtnPressedClosure : (()->())?
    
    static func build() -> UIViewController {
        
        let storyboard = UIStoryboard.MainTab
        let directMsgVC = storyboard.instantiateViewController(withIdentifier: "DirectMsgVC") as! DirectMsgVC
        let interactor = DirectMsgVCInteractor()
        let router = DirectMsgVCRouter(viewController: directMsgVC, interactor: interactor)
        let presenter = DirectMsgVCPresenter(view: directMsgVC, interactor: interactor, router: router)
        directMsgVC.presenter = presenter
        
        directMsgVC.navigationItem.hidesBackButton = true
        directMsgVC.navigationItem.title = "Chats"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        directMsgVC.navigationItem.leftBarButtonItem = backButton
        
        let addChatBtn = UIBarButtonItem(image: UIImage(systemName:"plus"), style: .plain, target: self, action: #selector(addChatBtnPressed))
        addChatBtn.tintColor = .black
        directMsgVC.navigationItem.rightBarButtonItem = addChatBtn
        
        DirectMsgVCBuilder.backButtonPressedClosure = {
            directMsgVC.backButtonPressed()
        }
        
        DirectMsgVCBuilder.addChatBtnPressedClosure = {
            directMsgVC.addChatBtnPressed()
        }
        
        return directMsgVC
    }
    
    @objc static func backButtonPressed() {
        backButtonPressedClosure?()
    }
    
    @objc static func addChatBtnPressed() {
        addChatBtnPressedClosure?()
    }
    
}

