//
//  Navigator.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import Foundation
import UIKit

class Navigator {
    static let shared = Navigator()
    private init(){}
    func navigate(storyboard: UIStoryboard?, destinationVCIdentifier: String?, completionHandler: @escaping (UIViewController?) -> Void) {
        guard let storyboard = storyboard, let identifier = destinationVCIdentifier else {
            completionHandler(nil) // Return nil if either parameter is missing
            return
        }
        let destinationVC = storyboard.instantiateViewController(withIdentifier: identifier)
        completionHandler(destinationVC)
    }
    
}
