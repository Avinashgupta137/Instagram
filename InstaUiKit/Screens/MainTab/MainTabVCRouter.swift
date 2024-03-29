//
//  MainTabVCRouter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

class MainTabVCRouter {
    var viewController : UIViewController
    typealias SubModules = (
        home:UIViewController,
        search:UIViewController,
        post:UIViewController,
        likes:UIViewController,
        profile:UIViewController
    )
    init(viewController : UIViewController){
        self.viewController = viewController
    }
}

extension MainTabVCRouter {
    static func tabs(subModules : SubModules) -> Tabs {
        let homeTabBarItems = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 11)
        let searchTabBarItems = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 12)
        let postTabBarItems = UITabBarItem(title: "Post", image: UIImage(systemName: "plus.app.fill"), tag: 13)
        let likesTabBarItems = UITabBarItem(title: "Likes", image: UIImage(systemName: "heart.fill"), tag: 14)
        let profileTabBarItems = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 15)
        
        subModules.home.tabBarItem = homeTabBarItems
        subModules.search.tabBarItem = searchTabBarItems
        subModules.post.tabBarItem = postTabBarItems
        subModules.likes.tabBarItem = likesTabBarItems
        subModules.profile.tabBarItem = profileTabBarItems
        
        return (
            home : subModules.home,
            search : subModules.search,
            post : subModules.post,
            likes : subModules.likes,
            profile : subModules.profile
        )
        
    }
}
