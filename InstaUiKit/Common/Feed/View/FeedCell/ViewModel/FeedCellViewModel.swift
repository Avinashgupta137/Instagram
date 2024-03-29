//
//  FeedCellViewModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 27/12/23.
//

import Foundation
import UIKit

final class FeedCellViewModel {
    func likePost(postPostDocumentID:String,
                  uid:String,
                  postUid:String,
                  cell:FeedCell){
        PostViewModel.shared.likePost(postDocumentID: postPostDocumentID, userUID: uid) { [weak self] success in
            if success {
                // Update the UI: Set the correct image for the like button
                cell.isLiked = true
                let imageName = cell.isLiked ? "heart.fill" : "heart"
                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
                FetchUserData.shared.fetchUserDataByUid(uid: postUid) { [weak self] result in
                    switch result {
                    case.success(let data):
                        if let data = data , let fmcToken = data.fcmToken {
                            if let name = FetchUserData.fetchUserInfoFromUserdefault(type: .name) {
                                PushNotification.shared.sendPushNotification(to: fmcToken, title: "InstaUiKit" , body: "\(name) Liked your post.")
                            }
                        }
                    case.failure(let error):
                        print(error)
                    }
                }
                
            }
        }
    }
    
    func unLikePost(postPostDocumentID:String,
                    uid:String,
                    cell:FeedCell){
        PostViewModel.shared.unlikePost(postDocumentID: postPostDocumentID, userUID: uid) { success in
            if success {
                // Update the UI: Set the correct image for the like button
                cell.isLiked = false
                let imageName = cell.isLiked ? "heart.fill" : "heart"
                cell.likeBtn.setImage(UIImage(systemName: imageName), for: .normal)
                cell.likeBtn.tintColor = cell.isLiked ? .red : .black
            }
        }
    }
}
