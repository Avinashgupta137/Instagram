//
//  HomeVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/12/23.
//

import Foundation
import UIKit


protocol HomeVCRouterProtocol {
    func goToDirectMsgVC()
    func goToNotificationVC()
}

class HomeVCRouter {
    var viewController : UIViewController
    init(viewController:UIViewController){
        self.viewController = viewController
    }
}

extension HomeVCRouter : HomeVCRouterProtocol {
    
    func goToDirectMsgVC(){
        let directMsgVC = DirectMsgVCBuilder.build()
        viewController.navigationController?.pushViewController(directMsgVC, animated: true)
    }
    
    func goToNotificationVC(){
        let notificationVC = NotificationVCBuilder.build()
        viewController.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
}

