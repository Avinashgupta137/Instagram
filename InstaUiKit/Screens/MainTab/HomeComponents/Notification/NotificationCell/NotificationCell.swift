//
//  NotificationCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/12/23.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var acceptBtn: RoundedButton!
    @IBOutlet weak var rejectBtn: RoundedButton!
    var acceptBtnBtnTapped: (() -> Void)?
    var rejectBtnBtnBtnTapped: (() -> Void)?
    var fetchCurrentUseClosure : (()->())?
    var viewModel = NotificationVCInteractor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func acceptBtnPressed(_ sender: UIButton) {
        acceptBtnBtnTapped?()
    }
    
    
    @IBAction func rejectBtnPressed(_ sender: UIButton) {
        rejectBtnBtnBtnTapped?()
    }
    
    func configureCell(currentUser:UserModel? , indexPath : Int ){
        if let cellData = currentUser , let uid = cellData.followersRequest?[indexPath] {
            DispatchQueue.global(qos: .background).async { [weak self] in
                FetchUserData.shared.fetchUserDataByUid(uid:uid) { result in
                    switch result {
                    case.success(let user):
                        if let user = user , let imgUrl = user.imageUrl , let name = user.name {
                            DispatchQueue.main.async {
                                self?.name.text = name
                                ImageLoader.loadImage(for: URL(string:imgUrl), into: (self?.userImg)!, withPlaceholder: UIImage(systemName: "person.fill"))
                            }
                            self?.acceptBtnBtnTapped = { [weak self] in
                                MessageLoader.shared.showLoader(withText: "Accepting..")
                                self?.viewModel.acceptFollowRequest(toFollowsUid: cellData.uid, whoFollowingsUid: uid){ bool in
                                    if let toFollowsUid = cellData.uid {
                                        StoreUserData.shared.saveFollowingsToFirebaseOfUser(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { _ in
                                            self?.viewModel.removeFollowRequest(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { bool in
                                                if let fmcToken = user.fcmToken , let name = cellData.name {
                                                    PushNotification.shared.sendPushNotification(to: fmcToken, title: "Request Accepted" , body: "\(name) Accepted your follow request.")
                                                }
                                                self?.fetchCurrentUseClosure?()
                                                MessageLoader.shared.hideLoader()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            self?.rejectBtnBtnBtnTapped = { [weak self] in
                                MessageLoader.shared.showLoader(withText: "Rejecting..")
                                if let toFollowsUid = cellData.uid {
                                    self?.viewModel.removeFollowRequest(toFollowsUid: toFollowsUid, whoFollowingsUid: uid) { bool in
                                        self?.fetchCurrentUseClosure?()
                                        MessageLoader.shared.hideLoader()
                                    }
                                }
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
