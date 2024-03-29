//
//  AddChatVCCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 06/12/23.
//

import UIKit

class AddChatVCCell: UITableViewCell {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
