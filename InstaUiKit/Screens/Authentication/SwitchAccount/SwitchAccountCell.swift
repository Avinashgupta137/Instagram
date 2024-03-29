//
//  SwitchAccountCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import UIKit

class SwitchAccountCell: UITableViewCell {
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    var selectButtonAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @IBAction func selectBtnPressed(_ sender: UIButton) {
        selectButtonAction?()
    }
}
