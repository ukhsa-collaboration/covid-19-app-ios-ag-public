//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Localization
import UserNotifications

public struct UserNotificationActionRegistration {
    
    public static func registerUserNotificationActions(notificationCenter: UNUserNotificationCenter) {
        let categories = createUserNotificationActions()
        notificationCenter.setNotificationCategories(categories)
    }
    
    private static func createUserNotificationActions() -> Set<UNNotificationCategory> {
        let enableExposureNotificationAction = UNNotificationAction(
            identifier: UserNotificationAction.enableExposureNotification.rawValue,
            title: localize(.exposure_notification_reminder_button),
            options: [.authenticationRequired, .foreground]
        )
        
        let enableExposureNotificationCategory =
            UNNotificationCategory(
                identifier: UserNotificationCategory.exposureNotification.rawValue,
                actions: [enableExposureNotificationAction],
                intentIdentifiers: []
            )
        
        return [enableExposureNotificationCategory]
    }
}
