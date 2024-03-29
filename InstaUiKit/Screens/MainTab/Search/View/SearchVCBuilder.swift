//
//  SearchVCBuilder.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/12/23.
//

import Foundation
import UIKit

final class SearchVCBuilder {
    static func build(factory:NavigationFactoryClosure) -> UIViewController {
        let storyboard = UIStoryboard.MainTab
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchVC") as!SearchVC
        searchVC.title = "Search"
        return factory(searchVC)
    }
}
