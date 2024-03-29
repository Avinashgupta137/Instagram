//
//  NotificationVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

protocol NotificationVCRouterProtocol {
    func goToUsersProfileView(user:UserModel , isFollowAndMsgBtnShow : Bool)
}

class NotificationVCRouter {
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
}

extension NotificationVCRouter : NotificationVCRouterProtocol {
    
    func goToUsersProfileView(user:UserModel , isFollowAndMsgBtnShow : Bool) {
        let usersProfileView = UsersProfileViewBuilder.build(user: user, isFollowAndMsgBtnShow: isFollowAndMsgBtnShow)
        viewController.navigationController?.pushViewController(usersProfileView, animated: true)
    }
   
}
