//
//  MainTabVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class MainTabVCBuilder {
    static func build(subModules : MainTabVCRouter.SubModules) -> UITabBarController {
        let tabs = MainTabVCRouter.tabs(subModules: subModules)
        let mainTabVC = MainTabVC(tabs: tabs)
        mainTabVC.tabBar.tintColor = .black
        return mainTabVC
    }
}
