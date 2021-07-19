//
// Copyright © 2021 DHSC. All rights reserved.
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
                userNotificationManager.removePending(type: .exposureNotificationSecondReminder)
            }
        }
    }
    
    public var isNotificationAuthorized: AnyPublisher<Bool, Never> {
        userNotificationStateController.$authorizationStatus.map { status in
            status == .authorized
        }.eraseToAnyPublisher()
    }
    
    @discardableResult
    public func scheduleUserNotification(in hours: Int) -> Date? {
        let date = currentDateProvider.currentDate
        let calendar = Calendar.current
        
        guard let newDate = calendar.date(byAdding: DateComponents(hour: hours), to: date) else {
            return nil
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        userNotificationManager.add(type: .exposureNotificationReminder, at: dateComponents, withCompletionHandler: nil)
        return newDate
    }
    
    /// The second reminder notification is shown at 4pm the day after the first reminder notification.
    public func scheduleSecondUserNotification(afterFirstReminderDate firstReminderDate: Date) {
        let calendar = Calendar.current
        
        guard let nextDayDate = calendar.date(byAdding: .day, value: 1, to: firstReminderDate),
            let secondReminderDate = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: nextDayDate)
        else {
            return
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: secondReminderDate)
        userNotificationManager.add(type: .exposureNotificationSecondReminder, at: dateComponents, withCompletionHandler: nil)
    }
}
