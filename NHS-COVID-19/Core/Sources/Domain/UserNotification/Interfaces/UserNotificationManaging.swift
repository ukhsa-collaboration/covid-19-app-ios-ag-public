//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import UserNotifications

public enum UserNotificationType: String {
    case postcode
    case venue
    case isolationState
    case exposureDetection
    case testResultReceived
    case appAvailability
    case exposureNotificationReminder
}

public enum UserNotificationCategory: String {
    case exposureNotification
}

public enum UserNotificationAction: String, CaseIterable {
    case enableExposureNotification
}

public protocol UserNotificationManaging {
    typealias ErrorHandler = (Bool, Error?) -> Void
    typealias AuthorizationStatusHandler = (AuthorizationStatus) -> Void
    typealias AuthorizationOptions = UNAuthorizationOptions
    typealias AuthorizationStatus = UNAuthorizationStatus
    typealias NotificationRequest = UNNotificationRequest
    
    func requestAuthorization(options: AuthorizationOptions, completionHandler: @escaping ErrorHandler)
    func getAuthorizationStatus(completionHandler: @escaping AuthorizationStatusHandler)
    func add(type: UserNotificationType, at: DateComponents?, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func removePending(type: UserNotificationType)
}
