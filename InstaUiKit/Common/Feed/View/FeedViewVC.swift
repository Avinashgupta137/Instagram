//
//  FeedViewVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 07/11/23.
//

import UIKit
import FirebaseAuth

class FeedViewVC: UIViewController {
    @IBOutlet weak var postTableViewOutlet: UITableView!
    var allPost : [PostAllDataModel]?
    var uid : String?
    let disPatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        postTableViewOutlet.register(nib, forCellReuseIdentifier: "FeedCell")
        if let currentUid = Auth.auth().currentUser?.uid {
            uid = currentUid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
        navigationItem.title = "All Posts"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        postTableViewOutlet.reloadData()
    }
    
    @objc func backButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
}

extension FeedViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = allPost?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        DispatchQueue.main.async { [weak self] in
            cell.configureCellData(post:self?.allPost?[indexPath.row], view: self!)
        }
        return cell
    }
    
}
