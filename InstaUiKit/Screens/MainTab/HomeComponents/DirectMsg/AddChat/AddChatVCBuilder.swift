//
//  AddChatVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/01/24.
//

import Foundation
import UIKit

final class AddChatVCBuilder {
    static func build(allUniqueUsersArray:[UserModel] , delegate: passChatUserBack? = nil) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let addChatVC = storyboard.instantiateViewController(withIdentifier: "AddChatVC") as! AddChatVC
        addChatVC.delegate = delegate
        addChatVC.allUniqueUsersArray = allUniqueUsersArray
        return addChatVC
    }
}
