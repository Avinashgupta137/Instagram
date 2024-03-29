//
//  CommentCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 08/11/23.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
