import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

class ChatVC: MessagesViewController {
    var currentUser: SenderType?
    var currentUserModel: UserModel?
    var receiverUser: UserModel?
    var messages: [Message] = []
    var viewModel = ChatVCModel()
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.isUserInteractionEnabled = true
        messageInputBar.inputTextView.isUserInteractionEnabled = true
        messageInputBar.delegate = self
        let sendButton = InputBarButtonItem()
        sendButton.setSize(CGSize(width: 50, height: 50), animated: false)
        let paperPlaneImage = UIImage(systemName: "paperplane")?.withRenderingMode(.alwaysTemplate)
        sendButton.setImage(paperPlaneImage, for: .normal)
        sendButton.tintColor = .black
        sendButton.onTouchUpInside { [weak self] _ in
            // Handle the send button tap
            self?.sendMessage(text: self?.messageInputBar.inputTextView.text ?? ""){ msg in
                if let fmcToken = self?.receiverUser?.fcmToken , let name = self?.currentUserModel?.name , let msg = msg {
                    print(fmcToken)
                    PushNotification.shared.sendPushNotification(to: fmcToken, title: name, body: msg)
                }
                
                if let senderId = self?.currentUserModel?.uid , let receiverId = self?.receiverUser?.uid {
                    StoreUserData.shared.saveUsersChatNotifications(senderId: senderId, receiverId: receiverId) { _ in}
                }
                
                if let userChatList = self?.receiverUser?.usersChatList , let senderId = self?.currentUserModel?.uid  , let receiverId = self?.receiverUser?.uid {
                    if !userChatList.contains(senderId){
                        StoreUserData.shared.saveUsersChatList(senderId: senderId, receiverId: receiverId) { _ in}
                    }
                }
                
            }
            self?.messageInputBar.inputTextView.text = ""
        }
        
        // Set the custom button as the sendButton
        messageInputBar.setRightStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([sendButton], forStack: .right, animated: false)
        
        let tapHideKeyboardGes = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        fetchData()
        
    }
    
    func fetchData(){
        MessageLoader.shared.showLoader(withText: "Messages Fetching")
        FetchUserData.shared.fetchCurrentUserFromFirebase { result in
            switch result {
            case .success(let data):
                MessageLoader.shared.hideLoader()
                if let data = data, let currentUserId = data.uid, let displayName = data.name, let receiverId = self.receiverUser?.uid {
                    self.currentUserModel = data
                    self.currentUser = Sender(senderId: currentUserId, displayName: displayName)
                    self.viewModel.observeMessages(currentUserId: currentUserId, receiverUserId: receiverId){ data in
                        if let data = data {
                            self.messages.append(data)
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(animated: true)
                            if let senderId = self.currentUserModel?.uid , let receiverId = self.receiverUser?.uid {
                                StoreUserData.shared.removeUsersChatNotifications(senderId: senderId, receiverId: receiverId) { _ in}
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error)
                MessageLoader.shared.hideLoader()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.hidesBackButton = true
        
        // Back button
        let backButton = UIBarButtonItem(image: UIImage(named: "BackArrow"), style: .plain, target: self, action: #selector(backButtonPressed))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUserView))
        
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        
        // User profile view
        let userProfileView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40)) // Reduced width to 120
        
        // Add user profile image view
        let userProfileImageView = UIImageView(frame: CGRect(x: -120, y: 0, width: 40, height: 40))
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.layer.cornerRadius = 20
        userProfileImageView.clipsToBounds = true
        if let imgUrl = receiverUser?.imageUrl {
            userProfileImageView.sd_setImage(with: URL(string: imgUrl))
        }
        userProfileImageView.addGestureRecognizer(tapGesture)
        // Add user name label
        let userNameLabel = UILabel(frame: CGRect(x: -75, y: 0, width: 200, height: 44)) // Reduced width to 75
        userNameLabel.text = receiverUser?.name
        userNameLabel.textColor = .black
        userNameLabel.font = UIFont.systemFont(ofSize: 16)
        userNameLabel.addGestureRecognizer(tapGesture)
        
        userProfileImageView.isUserInteractionEnabled = true
        userNameLabel.isUserInteractionEnabled = true
        
        
        userProfileView.isUserInteractionEnabled = true
        userProfileView.addGestureRecognizer(tapGesture)
        
        // Add subviews to the custom view
        userProfileView.addSubview(userProfileImageView)
        userProfileView.addSubview(userNameLabel)
        
        // Set the custom view as the titleView of the navigation item
        navigationItem.titleView = userProfileView
    }
    
    @objc func didTapUserView(){
        let storyboard = UIStoryboard.MainTab
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "UsersProfileView") as! UsersProfileView
        destinationVC.user = receiverUser
        destinationVC.isFollowAndMsgBtnShow = false
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    func sendMessage(text: String,completion:@escaping (String?) -> Void) {
        guard let currentUser = currentUser, let receiverUserId = receiverUser?.uid else {
            return
        }
        let messageRef = viewModel.messagesRef.childByAutoId()
        let message = [
            "senderId": currentUser.senderId,
            "displayName": currentUser.displayName,
            "messageId": messageRef.key ?? "",
            "sentDate": Formatter.iso8601.string(from: Date()),
            "kind": "text",
            "text": text
        ]
        messageRef.setValue(message)
        completion(text)
    }
}

extension ChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return currentUser ?? Sender(senderId: "", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentUser?.senderId {
            return #colorLiteral(red: 0.09133880585, green: 0.7034819722, blue: 0.9843640924, alpha: 1)
        }
        return .lightGray.withAlphaComponent(0.4)
    }
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8) // -> Them khoang trong giua cac tin nhan
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == currentUser?.senderId {
            if let imgUrl = currentUserModel?.imageUrl{
                avatarView.sd_setImage(with: URL(string: imgUrl))
            }
        } else {
            if let imgUrl = receiverUser?.imageUrl{
                avatarView.sd_setImage(with: URL(string: imgUrl))
            }
        }
    }
}

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessage(text: text){ msg in
            if let fmcToken = self.receiverUser?.fcmToken , let name = self.currentUserModel?.name , let msg = msg {
                PushNotification.shared.sendPushNotification(to: fmcToken, title: name, body: msg)
            }
        }
        inputBar.inputTextView.text = ""
    }
}

struct Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}

