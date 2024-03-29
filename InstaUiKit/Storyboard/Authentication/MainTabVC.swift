//
//  MainTabVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit

typealias Tabs = (
    home:UIViewController,
    search:UIViewController,
    post:UIViewController,
    likes:UIViewController,
    profile:UIViewController
)


class MainTabVC: UITabBarController {
    
    init(tabs:Tabs){
        super.init(nibName: nil, bundle: nil)
        viewControllers = [tabs.home,tabs.search,tabs.post,tabs.likes,tabs.profile]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
