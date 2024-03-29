//
//  PostVCCollectionCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class PostVCCollectionCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var checkMarkImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
    }
}
