//
//  LikesCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class LikesCell: UITableViewCell {
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var likeByLbl: UILabel!
    @IBOutlet weak var userImg: CircleImageView!
    var userImgPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userImgTapped))
        userImg.addGestureRecognizer(tapGesture)
        userImg.isUserInteractionEnabled = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Handle tap on userImg
    @objc func userImgTapped() {
        userImgPressed?()
    }
}

