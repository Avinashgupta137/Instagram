//
//  NotificationVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 30/11/23.
//

import UIKit


protocol NotificationVCProtocol : class {
    func configureTableView()
}


class NotificationVC: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var noNotificationView: UIView!
    
    var presenter : NotificationVCPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noNotificationView.isHidden = true
        presenter?.viewDidload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.fetchCurrentUser()
    }
    
    func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
}

extension NotificationVC : NotificationVCProtocol {
    func configureTableView() {
        if let followersRequest = presenter?.currentUser?.followersRequest {
            self.noNotificationView.isHidden = (followersRequest.isEmpty ? false : true)
        }
        self.tableViewOutlet.reloadData()
    }
}

extension NotificationVC : UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1  // Assuming you only have one section for follow requests
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Follow Requests"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.currentUser?.followersRequest?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        DispatchQueue.main.async {
            cell.configureCell(currentUser: self.presenter?.currentUser, indexPath: (indexPath.row))
        }
        cell.fetchCurrentUseClosure = { [weak self] in
            self?.presenter?.fetchCurrentUser()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cellData = presenter?.currentUser , let uid = cellData.followersRequest?[indexPath.row] {
            DispatchQueue.global(qos: .background).async { [weak self] in
                FetchUserData.shared.fetchUserDataByUid(uid:uid) { result in
                    switch result {
                    case.success(let user):
                        if let user = user {
                            DispatchQueue.main.async {
                                self?.presenter?.goToUsersProfileView(user: user, isFollowAndMsgBtnShow: true)
                            }
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    
}


