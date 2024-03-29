//
//  ChatVCModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 02/11/23.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}
