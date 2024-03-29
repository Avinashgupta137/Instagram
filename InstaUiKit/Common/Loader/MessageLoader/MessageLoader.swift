//
//  MessageLoader.swift
//  InstaUiKit
//
//  Created by IPS-161 on 06/12/23.
//

import Foundation
import JGProgressHUD
import UIKit

final class MessageLoader {
    static let shared = MessageLoader()
    
    private var hud: JGProgressHUD?

    private init() {
        setupHUD()
    }

    private func setupHUD() {
        hud = JGProgressHUD(style: .dark)
    }

    func showLoader(withText text: String, in view: UIView? = UIApplication.shared.keyWindow) {
        hud?.textLabel.text = text
        hud?.show(in: view!)
    }

    func hideLoader() {
        hud?.dismiss()
    }
}

