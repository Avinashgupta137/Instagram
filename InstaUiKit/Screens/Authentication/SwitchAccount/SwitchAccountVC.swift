//
//  SwitchAccountVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import UIKit
import SkeletonView


protocol passUserBack {
    func passUserBack(user:CDUsersModel)
}

protocol SwitchAccountVCProtocol : class {
    func fetchUsers(cdUser:[CDUsersModel]?,user:[UserModel]?)
    func makeTableViewSkeletonable()
}

class SwitchAccountVC: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var cdUser = [CDUsersModel]()
    var user = [UserModel]()
    var delegate : passUserBack?
    var presenter : SwitchAccountVCPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidload()
    }
    
    
}

extension SwitchAccountVC : SwitchAccountVCProtocol {
    
    func fetchUsers(cdUser:[CDUsersModel]?,user:[UserModel]?) {
        guard let cdUser = cdUser , let user = user else {
            return
        }
        self.cdUser = cdUser
        self.user = user
        configureTableView()
    }
    
    func makeTableViewSkeletonable() {
        tableViewOutlet.isSkeletonable = true
        tableViewOutlet.showAnimatedGradientSkeleton()
    }
    
    func configureTableView(){
        DispatchQueue.main.async {
            self.tableViewOutlet.stopSkeletonAnimation()
            self.view.stopSkeletonAnimation()
            self.tableViewOutlet.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
            self.tableViewOutlet.reloadData()
        }
    }
    
}

extension SwitchAccountVC : SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int{
        10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "SwitchAccountCell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchAccountCell", for: indexPath) as! SwitchAccountCell
        let data = user[indexPath.row]
        let imgUrl = data.imageUrl
        let name = data.name
        let userName = data.username
        
        DispatchQueue.main.async {
            ImageLoader.loadImage(for: URL(string:imgUrl ?? ""), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            cell.name.text = name
            cell.userName.text = userName
        }
        
        cell.selectButtonAction = { [weak self] in
            guard let self = self else { return }
            cell.selectBtn.setImage(UIImage(systemName: "smallcircle.circle.fill"), for: .normal)
            let selectedUser = data
            let passBackUser = self.cdUser.first(where: { $0.uid == selectedUser.uid })
            self.delegate?.passUserBack(user: passBackUser! )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard indexPath.row < user.count else {
                return
            }
            let deletedUser = user.remove(at: indexPath.row)
            if let deletedCdUserIndex = cdUser.firstIndex(where: { $0.uid == deletedUser.uid }) {
                let deletedCdUser = cdUser.remove(at: deletedCdUserIndex)
                CDUserManager.shared.deleteUser(withId: deletedCdUser.id) { _ in}
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}


