//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import UserNotifications

public class MockUserNotificationsManager: UserNotificationManaging {

    public var authorizationCompletionHandler: ErrorHandler?
    public var getSettingsCompletionHandler: AuthorizationStatusHandler?
    public var triggerAt: DateComponents?

    public var notificationType: UserNotificationType?
    public var removePendingNotificationType: UserNotificationType?
    public var removeAllShownNotificationType: UserNotificationType?
    public var removedAll: Bool?

    public init() {}

    public func requestAuthorization(options: AuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        authorizationCompletionHandler = completionHandler
    }

    public func getAuthorizationStatus(completionHandler: @escaping AuthorizationStatusHandler) {
        getSettingsCompletionHandler = completionHandler
    }

    public func add(type: UserNotificationType, at: DateComponents?, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        notificationType = type
        triggerAt = at
    }

    public func removePending(type: UserNotificationType) {
        removePendingNotificationType = type
    }

    public func removeAllDelivered(for type: UserNotificationType) {
        removeAllShownNotificationType = type
    }

    public func removeAll() {
        removedAll = true
    }
}
