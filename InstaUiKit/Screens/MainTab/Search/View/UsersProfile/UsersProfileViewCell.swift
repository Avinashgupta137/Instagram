//
//  UsersProfileViewCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 09/11/23.
//

import UIKit

class UsersProfileViewCell: UICollectionViewCell {
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var multiplePostIcon: UIImageView!
    var postImgPressed: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postImgTapped))
        postImg.addGestureRecognizer(tapGesture)
        postImg.isUserInteractionEnabled = true
    }
    @objc func postImgTapped() {
        postImgPressed?()
    }
}
