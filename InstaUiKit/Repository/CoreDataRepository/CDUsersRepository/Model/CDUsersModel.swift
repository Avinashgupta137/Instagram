//
//  CDUsersModel.swift
//  InstaUiKit
//
//  Created by IPS-161 on 29/11/23.
//

import Foundation

struct CDUsersModel : Decodable {
    var id: UUID
    var email: String
    var password: String
    var uid: String
}
