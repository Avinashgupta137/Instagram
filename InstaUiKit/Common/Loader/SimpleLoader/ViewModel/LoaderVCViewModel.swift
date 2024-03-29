//
//  LoaderVCViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import UIKit

class LoaderVCViewModel: NSObject {
    static let shared = LoaderVCViewModel()
    private var presentedLoaderVC: UIViewController?

    func showLoader() {
        Navigator.shared.navigate(storyboard: UIStoryboard.Common, destinationVCIdentifier: "LoaderVC") { destinationVC in
            if let destinationVC = destinationVC, let viewController = UIApplication.shared.keyWindow?.rootViewController {
                destinationVC.modalPresentationStyle = .overFullScreen
                viewController.present(destinationVC, animated: true, completion: nil)
                self.presentedLoaderVC = destinationVC
            }
        }
    }

    func hideLoader() {
        if let loaderVC = presentedLoaderVC {
            loaderVC.dismiss(animated: true, completion: nil)
            presentedLoaderVC = nil // Reset the reference
        }
    }
    
}

