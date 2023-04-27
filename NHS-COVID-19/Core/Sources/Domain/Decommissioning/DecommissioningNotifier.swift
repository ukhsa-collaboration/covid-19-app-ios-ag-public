//
// Copyright © 2023 DHSC. All rights reserved.
//

import Foundation
import UserNotifications

struct DecommissioningNotifier {
    var notificationManager: UserNotificationManaging

    let key: String = "DecommissioningNotificationAlert"
    private var hasAlertedUser: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    mutating func alertUser() {
        if !hasAlertedUser {
            notificationManager.add(type: .decommissioning, at: nil, withCompletionHandler: nil)
            hasAlertedUser = true
        }
    }
}
