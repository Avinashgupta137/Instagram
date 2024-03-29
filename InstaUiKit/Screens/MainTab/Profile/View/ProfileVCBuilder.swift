//
//  ProfileVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class ProfileVCBuilder {
    
    static var sideBtnTappedClosure: (() -> Void)?
    
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as!ProfileVC
        profileVC.title = "Profile"
        profileVC.navigationItem.rightBarButtonItem = setBarButton()
        ProfileVCBuilder.sideBtnTappedClosure = { [weak profileVC] in
            profileVC?.sideBtnTapped()
        }
        return factory(profileVC)
    }
    
    private static func setBarButton() -> UIBarButtonItem {
        if let nextButtonImage = UIImage(systemName: "line.3.horizontal")?.withRenderingMode(.alwaysOriginal) {
            let sideBtn = UIBarButtonItem(image: nextButtonImage, style: .plain, target: self, action: #selector(sideBtnTapped))
            return sideBtn
        }
        return UIBarButtonItem()
    }
    
    @objc private static func sideBtnTapped() {
        sideBtnTappedClosure?()
    }
    
}
