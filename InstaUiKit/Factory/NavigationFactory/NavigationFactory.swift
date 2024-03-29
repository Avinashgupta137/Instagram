//
//  NavigationFactory.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

typealias NavigationFactoryClosure = (UIViewController) -> UINavigationController

class NavigationFactory {
    static func build(rootView : UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootView)
        navigationController.navigationBar.isTranslucent = true
        return navigationController
    }
}
