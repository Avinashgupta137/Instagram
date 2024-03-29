//
//  LoaderVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/10/23.
//

import UIKit

class LoaderVC: UIViewController {
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var activityLoaderView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityLoader.startAnimating()
        activityLoaderView.layer.cornerRadius = 20
        activityLoaderView.layer.masksToBounds = true
    }
}

