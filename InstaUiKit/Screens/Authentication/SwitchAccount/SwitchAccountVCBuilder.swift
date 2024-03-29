//
//  SwitchAccountVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation
import UIKit

final class SwitchAccountVCBuilder {
    static func build(delegate: passUserBack? = nil) -> UIViewController {
        let storyboard = UIStoryboard.Authentication
        let switchAccountVC = storyboard.instantiateViewController(withIdentifier: "SwitchAccountVC") as! SwitchAccountVC
        switchAccountVC.delegate = delegate
        let interactor = SwitchAccountVCInteractor()
        let presenter = SwitchAccountVCPresenter(view: switchAccountVC , interactor: interactor)
        switchAccountVC.presenter = presenter
        return switchAccountVC
    }
}

