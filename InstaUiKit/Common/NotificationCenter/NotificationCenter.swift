//
//  NotificationCenter.swift
//  InstaUiKit
//
//  Created by IPS-161 on 01/01/24.
//

import Foundation

// Define a custom notification name
extension Notification.Name {
    static let notification = Notification.Name("NotificationCenter")
}

// Custom NotificationCenter Class
class NotificationCenterInternal {
    static let shared = NotificationCenterInternal()

    private init() {}

    // Add observer
    func addObserver(_ observer: Any, selector: Selector, name: Notification.Name) {
        Foundation.NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }

    // Remove observer
    func removeObserver(_ observer: Any, name: Notification.Name) {
        Foundation.NotificationCenter.default.removeObserver(observer, name: name, object: nil)
    }

    // Post notification
    func postNotification(name: Notification.Name) {
        Foundation.NotificationCenter.default.post(name: name, object: nil)
    }
}


