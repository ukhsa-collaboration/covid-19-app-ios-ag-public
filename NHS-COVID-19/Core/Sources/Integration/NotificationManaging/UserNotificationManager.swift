//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import Localization
import UserNotifications

class UserNotificationManager {
    
    private let manager = UNUserNotificationCenter.current()
    
    /// Creates a notification request based on a type
    /// - Parameter type: type of the notification
    /// - Returns: notification request with a title and body based on a passed type
    private func createRequest(for type: UserNotificationType, at date: DateComponents?) -> UNNotificationRequest {
        
        let trigger = date.map {
            UNCalendarNotificationTrigger(dateMatching: $0, repeats: false)
        }
        
        let content = self.content(for: type)
        
        let request = UNNotificationRequest(
            identifier: type.identifier,
            content: content,
            trigger: trigger
        )
        return request
    }
    
    private func content(for notificationType: UserNotificationType) -> UNNotificationContent {
        switch notificationType {
        case .postcode:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_postcode_risk_change_title)
                $0.body = localize(.alert_postcode_risk_change_body)
            }
        case .venue:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_venue_risk_change_title)
                $0.body = localize(.alert_venue_risk_change_body)
            }
        case .isolationState:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_isolation_state_change_title)
                $0.body = localize(.alert_isolation_state_change_body)
            }
        case .exposureDetection:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_exposure_detection_title)
                $0.body = localize(.alert_exposure_detection_body)
            }
        case .testResultReceived:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_test_result_received_title)
                $0.body = localize(.alert_test_result_received_body)
            }
        case .appAvailability:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_app_availability_changed_title)
                $0.body = localize(.alert_app_availability_changed_body)
            }
        case .latestAppVersionAvailable:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_latest_app_version_update_title)
                $0.body = localize(.alert_latest_app_version_update_body)
            }
        case .exposureNotificationReminder:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.exposure_notification_reminder_title)
                $0.categoryIdentifier = UserNotificationCategory.exposureNotification.rawValue
            }
        case .exposureDontWorry:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.dont_worry_notification_title)
                $0.body = localize(.dont_worry_notification_body)
            }
        case .shareKeysReminder:
            return configuring(UNMutableNotificationContent()) {
                $0.title = localize(.alert_share_keys_reminder_title)
                $0.body = localize(.alert_share_keys_reminder_body)
            }
        case .localMessage(let title, let body):
            return configuring(UNMutableNotificationContent()) {
                $0.title = title
                $0.body = body
            }
        }
    }
}

extension UserNotificationManager: UserNotificationManaging {
    
    func requestAuthorization(options: AuthorizationOptions, completionHandler: @escaping ErrorHandler) {
        manager.requestAuthorization(options: options, completionHandler: completionHandler)
    }
    
    public func getAuthorizationStatus(completionHandler: @escaping AuthorizationStatusHandler) {
        manager.getNotificationSettings { completionHandler($0.authorizationStatus) }
    }
    
    func add(type: UserNotificationType, at date: DateComponents?, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        
        let request = createRequest(for: type, at: date)
        manager.add(request, withCompletionHandler: completionHandler)
    }
    
    func removePending(type: UserNotificationType) {
        manager.removePendingNotificationRequests(withIdentifiers: [type.identifier])
    }
    
    func removeAllDelivered(for type: UserNotificationType) {
        manager.removeDeliveredNotifications(withIdentifiers: [type.identifier])
    }
}
