//
//  HomeVCCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 11/12/23.
//

import UIKit
import SkeletonView

class HomeVCCell: UITableViewCell {
    var allUniqueUsersArray : [UserModel]?
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var addStoryBtn: CircularButtonWithBorder!
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    var addStoryBtnPressed : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewOutlet.delegate = self
        collectionViewOutlet.dataSource = self
        if let url = FetchUserData.fetchUserInfoFromUserdefault(type: .profileUrl){
            ImageLoader.loadImage(for: URL(string:url), into: userImg, withPlaceholder: UIImage(systemName: "person.fill"))
        }
    }
    
    
    @IBAction func addStoryBtnPressed(_ sender: UIButton) {
        addStoryBtnPressed?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

extension HomeVCCell: SkeletonCollectionViewDataSource  , SkeletonCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allUniqueUsersArray?.count ?? 0
    }
    
    func collectionSkeletonView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "StoriesCell"
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCell", for: indexPath) as! StoriesCell
        if let uid = allUniqueUsersArray?[indexPath.row].uid,
           let name = allUniqueUsersArray?[indexPath.row].name,
           let imgUrl = allUniqueUsersArray?[indexPath.row].imageUrl{
            DispatchQueue.main.async { [weak self] in
                ImageLoader.loadImage(for: URL(string: imgUrl), into: cell.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                cell.userName.text = name
            }
        }
        return cell
    }
    
}
