//
//  DirectMsgCell.swift
//  InstaUiKit
//
//  Created by IPS-161 on 28/07/23.
//

import UIKit

class DirectMsgCell: UITableViewCell {
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var directMsgBtn: UIButton!
    var directMsgButtonTapped: (() -> Void)?
    var viewModel = DirectMsgVCInteractor()
    @IBAction func directMsgBtnPressed(_ sender: UIButton) {
        directMsgButtonTapped?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureCell(currentUser:UserModel?,element:UserModel?){
        // Reset cell content to avoid reuse issues
        userImg.image = nil
        nameLbl.text = nil
        userNameLbl.text = nil
        
        if let name = element?.name,
           let userName = element?.username,
           let imgUrl = element?.imageUrl,
           let receiverUserId = element?.uid{
            
            DispatchQueue.main.async {
                ImageLoader.loadImage(for: URL(string: imgUrl), into: self.userImg, withPlaceholder: UIImage(systemName: "person.fill"))
                self.nameLbl.text = name
                self.userNameLbl.text = "Loading..."
            }
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                if let currentUser = currentUser , let currentUid = currentUser.uid , let notification = currentUser.usersChatNotification {
                    self?.viewModel.observeLastTextMessage(currentUserId: currentUid, receiverUserId: receiverUserId) { textMsg, senderUid in
                        print(textMsg)
                        DispatchQueue.main.async {
                            if let textMsg = textMsg, let senderUid = senderUid {
                                self?.userNameLbl.text = "\(senderUid == currentUid ? "You: " : "\(notification.contains(receiverUserId) ? "🔵":"") ")\(textMsg)"
                            }
                        }
                    }
                }
            }
            
        }
    }
    
}
