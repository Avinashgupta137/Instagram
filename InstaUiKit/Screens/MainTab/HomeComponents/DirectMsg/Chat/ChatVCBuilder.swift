//
//  ChatVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/01/24.
//

import Foundation
import UIKit

final class ChatVCBuilder {
    static func build(user:UserModel) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let chatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.receiverUser = user
        return chatVC
    }
}
