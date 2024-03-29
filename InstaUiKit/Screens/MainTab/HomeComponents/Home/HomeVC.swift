//
//  HomeVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 26/07/23.
//

import UIKit
import SkeletonView
import RxSwift

protocol HomeVCProtocol : class {
    func configureTableView()
    func makeSkeletonable()
    func confugureCell()
    func setupRefreshControl()
    func directMsgBtnTapped()
    func notificationBtnTapped()
}


class HomeVC: UIViewController {
    
    @IBOutlet weak var feedTableView: UITableView!
    var presenter : HomeVCPresenterProtocol?
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.fetchAllNotifications(view: self)
    }
    
}


extension HomeVC : HomeVCProtocol {
    
    func confugureCell() {
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        feedTableView.register(nib, forCellReuseIdentifier: "FeedCell")
    }
    
    func makeSkeletonable(){
        feedTableView.isSkeletonable = true
        feedTableView.showAnimatedGradientSkeleton()
    }
    
    func configureTableView(){
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.feedTableView.stopSkeletonAnimation()
            self?.view.stopSkeletonAnimation()
            self?.feedTableView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            self?.feedTableView.reloadData()
        }
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        feedTableView.addSubview(refreshControl)
    }
    
    @objc private func refresh() {
        self.makeSkeletonable()
        presenter?.fetchAllNotifications(view: self)
        presenter?.configureTableView()
    }
    
    func directMsgBtnTapped(){
        presenter?.goToDirectMsgVC()
    }
    
    func notificationBtnTapped(){
        presenter?.goToNotificationVC()
    }
    
}


extension HomeVC: SkeletonTableViewDataSource, SkeletonTableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        if section == 1 {
            return presenter?.allPost.count ?? 0
        }
        return 0
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 11
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "FeedCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "HomeVCCell", for: indexPath) as! HomeVCCell
            cell2.allUniqueUsersArray = presenter?.allUniqueUsersArray
            cell2.addStoryBtnPressed = { [weak self] in
                Navigator.shared.navigate(storyboard: UIStoryboard.MainTab, destinationVCIdentifier: "AddStoryVC") { [weak self] destinationVC in
                    if let destinationVC = destinationVC {
                        self?.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                }
            }
            return cell2
        }
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
            DispatchQueue.main.async { [weak self] in
                cell.configureCellData(post:self?.presenter?.allPost[indexPath.row], view: self!)
            }
            return cell
        }
        return UITableViewCell()
    }
    
}



