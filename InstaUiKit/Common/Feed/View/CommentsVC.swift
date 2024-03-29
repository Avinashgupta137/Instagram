//
//  CommentsVC.swift
//  InstaUiKit
//
//  Created by IPS-161 on 08/11/23.
//

import UIKit
import SwiftUI

class CommentsVC: UIViewController {
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var commentTxtFld: UITextField!
    var allPost : PostAllDataModel?
    var currentPostData : PostAllDataModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Comments"
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        Data.shared.getData(key: "ProfileUrl") { (result:Result<String?,Error>) in
            switch result {
            case .success(let url):
                if let url = url {
                    ImageLoader.loadImage(for: URL(string: url), into: self.userImg , withPlaceholder: UIImage(systemName: "person.fill"))
                }
            case .failure(let failure):
                print(failure)
            }
        }
        fetchCurrentPostData()
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func postBtnPressed(_ sender: UIButton) {
        if let allPost = allPost , let comment = commentTxtFld.text , let postDocumentID = allPost.postDocumentID{
            PostViewModel.shared.addCommentToPost(postDocumentID: postDocumentID, commentText: comment) { value in
                self.fetchCurrentPostData()
            }
        }
    }
    
    func fetchCurrentPostData(){
        if let allPost = allPost , let postDocumentID = allPost.postDocumentID {
            PostViewModel.shared.fetchPostbyPostDocumentID(byPostDocumentID: postDocumentID) { result in
                switch result {
                case.success(let data):
                    if let data = data {
                        print(data)
                        self.currentPostData = data
                        self.tableViewOutlet.reloadData()
                    }
                case.failure(let error):
                    print(error)
                }
            }
        }
    }
    
}

extension CommentsVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPostData?.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        if let postData = currentPostData?.comments?[indexPath.row],
           let uid = postData["uid"] as? String,
           let comment = postData["comment"] as? String {
            DispatchQueue.main.async {
                FetchUserData.shared.fetchUserDataByUid(uid: uid) { result in
                    switch result {
                    case .success(let data):
                        if let data = data , let url = data.imageUrl {
                            ImageLoader.loadImage(for: URL(string: url), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                cell.commentLbl.text = comment
            }
        }
        return cell
    }
}
