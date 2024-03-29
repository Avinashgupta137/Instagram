//
//  DirectMsgVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

protocol DirectMsgVCRouterProtocol {
    func goToAddChatVC(allUniqueUsersArray:[UserModel])
    func goToChatVC(user:UserModel)
}

class DirectMsgVCRouter: passChatUserBack {
   
    var viewController : UIViewController
    var interactor : DirectMsgVCInteractorProtocol
    
    init(viewController:UIViewController , interactor : DirectMsgVCInteractorProtocol ){
        self.viewController = viewController
        self.interactor = interactor
    }
    
}

extension DirectMsgVCRouter : DirectMsgVCRouterProtocol {
    
    func goToChatVC(user: UserModel) {
        let chatVC = ChatVCBuilder.build(user: user)
        viewController.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func goToAddChatVC(allUniqueUsersArray: [UserModel]) {
        let addChatVC = AddChatVCBuilder.build(allUniqueUsersArray: allUniqueUsersArray, delegate: self)
        viewController.navigationController?.present(addChatVC, animated: true, completion: nil)
    }
    
    func passChatUserBack(user: UserModel?) {
        if let user = user {
            if let userUid = user.uid {
                MessageLoader.shared.showLoader(withText: "Adding Users")
                if let currentUser = interactor.currentUser , let  senderId = currentUser.uid , let receiverId = user.uid {
                    StoreUserData.shared.saveUsersChatList(senderId: senderId, receiverId: receiverId) { result in
                        switch result {
                        case.success():
                            print("")
                            NotificationCenterInternal.shared.postNotification(name: .notification)
                        case.failure(let error):
                            print(error)
                            MessageLoader.shared.hideLoader()
                        }
                    }
                }
            }
        }
    }
    
}

