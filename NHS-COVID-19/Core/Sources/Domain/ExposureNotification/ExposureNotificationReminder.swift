//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public class ExposureNotificationReminder {
    private var userNotificationManager: UserNotificationManaging
    private var userNotificationStateController: UserNotificationsStateController
    private var currentDateProvider: DateProviding
    private var cancellable: AnyCancellable
    
    init(
        userNotificationManager: UserNotificationManaging,
        userNotificationStateController: UserNotificationsStateController,
        currentDateProvider: DateProviding,
        exposureNotificationEnabled: AnyPublisher<Bool, Never>
    ) {
        self.userNotificationManager = userNotificationManager
        self.userNotificationStateController = userNotificationStateController
        self.currentDateProvider = currentDateProvider
        
        cancellable = exposureNotificationEnabled.sink { enabled in
            if enabled {
                userNotificationManager.removePending(type: .exposureNotificationReminder)
            }
        }
    }
    
    public var isNotificationAuthorized: AnyPublisher<Bool, Never> {
        userNotificationStateController.$authorizationStatus.map { status in
            status == .authorized
        }.eraseToAnyPublisher()
    }
    
    public func scheduleUserNotification(in hours: Int) {
        let date = currentDateProvider.currentDate
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: DateComponents(hour: hours), to: date) {
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
            userNotificationManager.add(type: .exposureNotificationReminder, at: dateComponents, withCompletionHandler: nil)
        }
    }
}
