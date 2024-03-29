import Foundation
import MessageKit
import Firebase

class ChatVCModel {
    var messagesRef: DatabaseReference!
    
    func observeMessages(currentUserId: String?, receiverUserId: String? , completion: @escaping (Message?) -> Void) {
        if let currentUserId = currentUserId, let receiverUserId = receiverUserId {
            messagesRef = Database.database().reference().child("messages").child(chatPath(senderId: currentUserId, receiverId: receiverUserId))
        } else {
            // Handle the case where either currentUserId or receiverUserId is nil
            print("Error: currentUserId or receiverUserId is nil")
        }
        messagesRef.observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let senderId = messageData["senderId"] as? String,
                  let displayName = messageData["displayName"] as? String,
                  let messageId = messageData["messageId"] as? String,
                  let sentDateString = messageData["sentDate"] as? String,
                  let sentDate = Formatter.iso8601.date(from: sentDateString),
                  let kindString = messageData["kind"] as? String else {
                      return
                  }
            
            let sender = Sender(senderId: senderId, displayName: displayName)
            let messageKind: MessageKind
            
            switch kindString {
            case "text":
                let text = messageData["text"] as? String ?? ""
                messageKind = .text(text)
                // Add more cases for other message types if needed
            default:
                return
            }
            
            let message = Message(sender: sender, messageId: messageId, sentDate: sentDate, kind: messageKind)
            DispatchQueue.main.async {
                completion(message)
            }
        }
    }
    
    func chatPath(senderId: String, receiverId: String) -> String {
        return senderId < receiverId ? "\(senderId)_\(receiverId)" : "\(receiverId)_\(senderId)"
    }
    
}

