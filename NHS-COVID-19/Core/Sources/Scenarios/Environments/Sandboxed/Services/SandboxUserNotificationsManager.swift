//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain
import Foundation
import UIKit
import UserNotifications

class SandboxUserNotificationsManager: UserNotificationManaging {
    typealias AlertText = Sandbox.Text.UserNotification
    
    private let host: SandboxHost
    var authorizationStatus: AuthorizationStatus
    
    init(host: SandboxHost) {
        self.host = host
        
        let allowed = host.initialState.userNotificationsAuthorized
        authorizationStatus = allowed ? .authorized : .notDetermined
    }
    
    func requestAuthorization(options: AuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        let alert = UIAlertController(
            title: AlertText.authorizationAlertTitle.rawValue,
            message: AlertText.authorizationAlertMessage.rawValue,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertDoNotAllow.rawValue, style: .default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertAllow.rawValue, style: .default, handler: { [weak self] _ in
            self?.authorizationStatus = .authorized
            completionHandler(true, nil)
        }))
        host.container?.show(alert, sender: nil)
    }
    
    func getAuthorizationStatus(completionHandler: @escaping AuthorizationStatusHandler) {
        completionHandler(authorizationStatus)
    }
    
    func add(type: UserNotificationType, at: DateComponents?, withCompletionHandler completionHandler: ((Error?) -> Void)?) {}
    
    func removePending(type: UserNotificationType) {}
}
