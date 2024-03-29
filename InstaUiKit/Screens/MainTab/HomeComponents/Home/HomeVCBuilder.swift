//
//  HomeVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class HomeVCBuilder {
    
    private static var notificationCountForDirectMsg : Int = 0
    private static var notificationCountForNotificationBtn: Int = 0
    private static var isnotificationShowForDirectMsg = false
    private static var isnotificationShowForNotificationBtn = false
    private static var viewModel = HomeVCInteractor()
    private static let dispatchGroup = DispatchGroup()
    static var directMsgBtnTappedClosure: (() -> Void)?
    static var notificationBtnTappedClosure: (() -> Void)?
    
    
    static func build(factory: NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let interactor = HomeVCInteractor()
        let router = HomeVCRouter(viewController: homeVC)
        let presenter = HomeVCPresenter(view: homeVC, interactor: interactor, router: router)
        homeVC.presenter = presenter
        homeVC.navigationItem.leftBarButtonItems = [configureInstaLogo()]
        homeVC.navigationItem.rightBarButtonItems = configureBarButtons(isdirectMsgHaveNotification: isnotificationShowForDirectMsg, isNotificationBtnHaveNotification: isnotificationShowForNotificationBtn, notificationCountForDirectMsg: notificationCountForDirectMsg, notificationCountForNotificationBtn: notificationCountForNotificationBtn)
        HomeVCBuilder.directMsgBtnTappedClosure = { [weak homeVC] in
            homeVC?.directMsgBtnTapped()
        }
        
        HomeVCBuilder.notificationBtnTappedClosure = { [weak homeVC] in
            homeVC?.notificationBtnTapped()
        }
        return factory(homeVC)
    }
    
    
    private static func configureInstaLogo() -> UIBarButtonItem {
        let userProfileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileImageView.contentMode = .scaleToFill
        userProfileImageView.clipsToBounds = true
        userProfileImageView.image = UIImage(named: "InstaLogo")
        let userProfileView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        userProfileView.addSubview(userProfileImageView)
        let userProfileItem = UIBarButtonItem(customView: userProfileView)
        return userProfileItem
    }
    
    static func fetchAllKindNotifications(view:UIViewController){
        
        dispatchGroup.enter()
        viewModel.fetchAllNotifications { result in
            defer { dispatchGroup.leave() }
            switch result {
            case .success(let notificationCount):
                print(notificationCount)
                if notificationCount != 0 {
                    self.isnotificationShowForNotificationBtn = true
                    self.notificationCountForNotificationBtn = notificationCount
                } else {
                    self.isnotificationShowForNotificationBtn = false
                }
            case .failure(let error):
                print(error)
            }
        }
        
        dispatchGroup.enter()
        viewModel.fetchUserChatNotificationCount { result in
            defer { dispatchGroup.leave() }
            switch result {
            case .success(let notificationCount):
                print(notificationCount)
                if let notificationCount = notificationCount, notificationCount != 0 {
                    self.isnotificationShowForDirectMsg = true
                    self.notificationCountForDirectMsg = notificationCount
                } else {
                    self.isnotificationShowForDirectMsg = false
                }
            case .failure(let error):
                print(error)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            view.navigationItem.rightBarButtonItems = configureBarButtons(
                isdirectMsgHaveNotification: self.isnotificationShowForDirectMsg,
                isNotificationBtnHaveNotification: self.isnotificationShowForNotificationBtn,
                notificationCountForDirectMsg: self.notificationCountForDirectMsg,
                notificationCountForNotificationBtn: self.notificationCountForNotificationBtn
            )
        }
        
    }
    
    
    private static func configureBarButtons(isdirectMsgHaveNotification: Bool, isNotificationBtnHaveNotification: Bool, notificationCountForDirectMsg: Int, notificationCountForNotificationBtn: Int) ->  [UIBarButtonItem] {
        
        var barButtonItems: [UIBarButtonItem] = []
        
        if isdirectMsgHaveNotification {
            let directMsgBtn = createCircularButtonWithLabel(image: UIImage(systemName: "paperplane"), action: #selector(directMsgBtnTapped), count: notificationCountForDirectMsg)
            barButtonItems.append(directMsgBtn)
        } else {
            let directMsgBtn = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(directMsgBtnTapped))
            directMsgBtn.tintColor = UIColor.black
            barButtonItems.append(directMsgBtn)
        }
        
        if isNotificationBtnHaveNotification {
            let notificationBtn = createCircularButtonWithLabel(image: UIImage(systemName: "bell"), action: #selector(notificationBtnTapped), count: notificationCountForNotificationBtn)
            barButtonItems.append(notificationBtn)
        } else {
            let notificationBtn = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(notificationBtnTapped))
            notificationBtn.tintColor = UIColor.black
            barButtonItems.append(notificationBtn)
        }
        
        return barButtonItems
    }
    
    private static func createCircularButtonWithLabel(image: UIImage?, action: Selector, count: Int) -> UIBarButtonItem {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action: action, for: .touchUpInside)
        
        let label = UILabel(frame: CGRect(x: 20, y: -8, width: 20, height: 20))
        label.backgroundColor = .red
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = label.frame.width / 2
        label.text = "\(count)"
        
        container.addSubview(button)
        container.addSubview(label)
        
        // Add Auto Layout constraints to position the button and label within the container
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.widthAnchor.constraint(equalTo: container.widthAnchor),
            button.heightAnchor.constraint(equalTo: container.heightAnchor),
            
            label.widthAnchor.constraint(equalToConstant: 20),
            label.heightAnchor.constraint(equalToConstant: 20),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        return UIBarButtonItem(customView: container)
    }
    
    
    @objc static func directMsgBtnTapped(){
        print("directMsgBtnTapped")
        directMsgBtnTappedClosure?()
    }
    
    @objc static func notificationBtnTapped() {
        print("notificationBtnTapped")
        notificationBtnTappedClosure?()
    }
    
}
