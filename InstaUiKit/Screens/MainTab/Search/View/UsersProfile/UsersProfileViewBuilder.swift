//
//  UsersProfileViewBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit

final class UsersProfileViewBuilder {
    static func build(user:UserModel , isFollowAndMsgBtnShow : Bool) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let usersProfileView = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        usersProfileView.user = user
        usersProfileView.isFollowAndMsgBtnShow = isFollowAndMsgBtnShow
        return usersProfileView
    }
}
