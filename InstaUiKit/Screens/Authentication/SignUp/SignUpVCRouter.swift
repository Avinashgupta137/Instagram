//
//  SignUpVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation
import UIKit

protocol SignUpVCRouterProtocol {
    func goToMainTabVC()
}

class SignUpVCRouter {
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
}

extension SignUpVCRouter : SignUpVCRouterProtocol {
    
    func goToMainTabVC(){
        let subModules = (
            home: HomeVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            search: SearchVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            post: PostVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            likes: LikesVCBuilder.build(factory: NavigationFactory.build(rootView:)),
            profile: ProfileVCBuilder.build(factory: NavigationFactory.build(rootView:))
        )
        let mainTabVC = MainTabVCBuilder.build(subModules: subModules)
        // Access the window from the SceneDelegate
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = mainTabVC
            window.makeKeyAndVisible()
        }
    }
    
}
