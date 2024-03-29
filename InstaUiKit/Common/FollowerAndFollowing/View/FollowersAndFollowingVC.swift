//
//  FollowersAndFollowingVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/11/23.
//

import UIKit

class FollowersAndFollowingVC: UIViewController {
    @IBOutlet weak var segmentControlOutlet: UISegmentedControl!
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var tableviewOutlet: UITableView!
    var user: UserModel?
    var segmentIndex: Int = 0
    var followers: [UserModel] = []
    var followings: [UserModel] = []
    var filterdFollowers: [UserModel] = []
    var filterdFollowings: [UserModel] = []
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FollowingCell", bundle: nil)
        tableviewOutlet.register(nib, forCellReuseIdentifier: "FollowingCell")
        searchBarOutlet.delegate = self
        searchBarOutlet.showsCancelButton = true
        fetchFollowerAndFollowings(){ [self] in
            filterdFollowers = followers
            filterdFollowings = followings
            self.tableviewOutlet.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentControlPressed(_ sender: UISegmentedControl) {
        segmentIndex = sender.selectedSegmentIndex
        tableviewOutlet.reloadData()
    }
    
    func fetchFollowerAndFollowings(completion: @escaping () -> Void) {
        if let user = user {
            let group = DispatchGroup()
            
            group.enter()
            if let followersUids = user.followers {
                for followersUid in followersUids {
                    group.enter()
                    FetchUserData.shared.fetchUserDataByUid(uid: followersUid) { result in
                        defer { group.leave() }
                        switch result {
                        case .success(let userData):
                            if let userData = userData {
                                self.followers.append(userData)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                group.leave()
            }
            
            group.enter()
            if let followingsUids = user.followings {
                for followingsUid in followingsUids {
                    group.enter()
                    FetchUserData.shared.fetchUserDataByUid(uid: followingsUid) { result in
                        defer { group.leave() }
                        switch result {
                        case .success(let userData):
                            if let userData = userData {
                                self.followings.append(userData)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                group.leave()
            }
            
            group.notify(queue: DispatchQueue.main) {
                completion()  // Invoke the completion handler when all data is fetched
            }
        }
    }
    
}



extension FollowersAndFollowingVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentIndex == 0 {
            return filterdFollowers.count
        }else{
            return filterdFollowings.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell", for: indexPath) as! FollowingCell
        cell.followBtn.isHidden = true
        if segmentIndex == 0 {
            let data = filterdFollowers[indexPath.row]
            DispatchQueue.main.async {
                cell.nameLbl.text = data.name
                cell.userNameLbl.text = data.username
                ImageLoader.loadImage(for: URL(string: data.imageUrl ?? ""), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            }
            return cell
        }else{
            let data = filterdFollowings[indexPath.row]
            DispatchQueue.main.async {
                cell.nameLbl.text = data.name
                cell.userNameLbl.text = data.username
                ImageLoader.loadImage(for: URL(string: data.imageUrl ?? ""), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        if segmentIndex == 0 {
            let data = filterdFollowers[indexPath.row]
            destinationVC.user = data
            destinationVC.isFollowAndMsgBtnShow = true
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }else{
            let data = filterdFollowings[indexPath.row]
            destinationVC.user = data
            destinationVC.isFollowAndMsgBtnShow = true
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
}


extension FollowersAndFollowingVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterUsersByName()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if segmentIndex == 0 {
            filterdFollowers = searchText.isEmpty ? followers : followers.filter { user in
                return user.name?.range(of: searchText, options: .caseInsensitive) != nil
            }
        } else {
            filterdFollowings = searchText.isEmpty ? followings : followings.filter { user in
                return user.name?.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
        
        tableviewOutlet.reloadData()
    }
    
    private func filterUsersByName() {
        searchBarOutlet.text = ""
        if segmentIndex == 0 {
            filterdFollowers = followers
        } else {
            filterdFollowings = followings
        }
        
        tableviewOutlet.reloadData()
    }
}

