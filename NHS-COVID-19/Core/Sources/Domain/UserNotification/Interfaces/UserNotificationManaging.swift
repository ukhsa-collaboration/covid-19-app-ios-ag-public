//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import UserNotifications

public enum UserNotificationType: Equatable {
    case postcode
    case venue
    case isolationState
    case exposureDetection
    case testResultReceived
    case appAvailability
    case latestAppVersionAvailable
    case exposureNotificationReminder
    case exposureDontWorry
    case shareKeysReminder
    case localMessage(
        title: String,
        body: String
    )
    
    public var identifier: String {
        switch self {
        case .postcode:
            return "postcode"
        case .venue:
            return "venue"
        case .isolationState:
            return "isolationState"
        case .exposureDetection:
            return "exposureDetection"
        case .testResultReceived:
            return "testResultReceived"
        case .appAvailability:
            return "appAvailability"
        case .latestAppVersionAvailable:
            return "latestAppVersionAvailable"
        case .exposureNotificationReminder:
            return "exposureNotificationReminder"
        case .exposureDontWorry:
            return "exposureDontWorry"
        case .shareKeysReminder:
            return "shareKeysReminder"
        case .localMessage(_, _):
            return "localMessageUpdate"
        }
    }
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
    func removeAllDelivered(for type: UserNotificationType)
}
