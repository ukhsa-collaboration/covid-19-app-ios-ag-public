//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Scenarios
import XCTest
@testable import Domain

class ExposureNotificationReminderTests: XCTestCase {
    private var notificationManager: MockUserNotificationManager!
    private var notificationStateController: UserNotificationsStateController!
    
    override func setUp() {
        notificationManager = MockUserNotificationManager()
        notificationStateController = UserNotificationsStateController(
            manager: notificationManager,
            notificationCenter: NotificationCenter()
        )
    }
    
    func testAuthorizationStateAuthorized() throws {
        notificationManager.authorizationStatus = .authorized
        notificationStateController.authorize()
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { Date() },
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
        
        let isEnabled = try reminder.isNotificationAuthorized.await().get()
        
        XCTAssertTrue(isEnabled)
    }
    
    func testAuthorizationStateDenied() throws {
        notificationManager.authorizationStatus = .denied
        notificationStateController.authorize()
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { Date() },
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
        
        let isEnabled = try reminder.isNotificationAuthorized.await().get()
        
        XCTAssertFalse(isEnabled)
    }
    
    func testAuthorizationStateNotDetermined() throws {
        notificationManager.authorizationStatus = .notDetermined
        notificationStateController.authorize()
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { Date() },
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
        
        let isEnabled = try reminder.isNotificationAuthorized.await().get()
        
        XCTAssertFalse(isEnabled)
    }
    
    func testScheduleNotificationLessThanOneDay() throws {
        let currentDate = Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { currentDate },
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
        
        let hours = 5
        
        reminder.scheduleUserNotification(in: hours)
        
        let newDate = Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 13))!
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        
        XCTAssertEqual(notificationManager.notificationType, .exposureNotificationReminder)
        XCTAssertEqual(notificationManager.triggerAt, dateComponents)
    }
    
    func testScheduleNotificationMoreThanOneDay() throws {
        let currentDate = Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { currentDate },
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
        
        let hours = 30
        
        reminder.scheduleUserNotification(in: hours)
        
        let newDate = Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 8, hour: 14))!
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        
        XCTAssertEqual(notificationManager.notificationType, .exposureNotificationReminder)
        XCTAssertEqual(notificationManager.triggerAt, dateComponents)
    }
    
    func testScheduleNotificationMonthChange() throws {
        let currentDate = Calendar.current.date(from: DateComponents(year: 2020, month: 5, day: 31, hour: 22))!
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { currentDate },
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
        
        let hours = 4
        
        reminder.scheduleUserNotification(in: hours)
        
        let newDate = Calendar.current.date(from: DateComponents(year: 2020, month: 6, day: 1, hour: 2))!
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        
        XCTAssertEqual(notificationManager.notificationType, .exposureNotificationReminder)
        XCTAssertEqual(notificationManager.triggerAt, dateComponents)
    }
    
    func testScheduleNotificationYearChange() throws {
        let currentDate = Calendar.current.date(from: DateComponents(year: 2020, month: 12, day: 31, hour: 22))!
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { currentDate },
            exposureNotificationEnabled: Just(true).eraseToAnyPublisher()
        )
        
        let hours = 5
        
        reminder.scheduleUserNotification(in: hours)
        
        let newDate = Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 1, hour: 3))!
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        
        XCTAssertEqual(notificationManager.notificationType, .exposureNotificationReminder)
        XCTAssertEqual(notificationManager.triggerAt, dateComponents)
    }
    
    func testScheduleAndRemoveNotification() throws {
        let currentDate = Calendar.current.date(from: DateComponents(year: 2020, month: 12, day: 31, hour: 22))!
        
        let exposureNotificationEnabled = CurrentValueSubject<Bool, Never>(false)
        
        let reminder = ExposureNotificationReminder(
            userNotificationManager: notificationManager,
            userNotificationStateController: notificationStateController,
            currentDateProvider: { currentDate },
            exposureNotificationEnabled: exposureNotificationEnabled.eraseToAnyPublisher()
        )
        
        let hours = 5
        
        reminder.scheduleUserNotification(in: hours)
        
        let newDate = Calendar.current.date(from: DateComponents(year: 2021, month: 1, day: 1, hour: 3))!
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        
        XCTAssertEqual(notificationManager.notificationType, .exposureNotificationReminder)
        XCTAssertEqual(notificationManager.triggerAt, dateComponents)
        
        exposureNotificationEnabled.send(true)
        
        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(notificationManager.triggerAt)
        
    }
    
    private class MockUserNotificationManager: UserNotificationManaging {
        public var triggerAt: DateComponents?
        public var notificationType: UserNotificationType?
        public var authorizationStatus = AuthorizationStatus.notDetermined
        
        func requestAuthorization(options: AuthorizationOptions, completionHandler: @escaping ErrorHandler) {
            completionHandler(true, nil)
        }
        
        func getAuthorizationStatus(completionHandler: @escaping AuthorizationStatusHandler) {
            completionHandler(authorizationStatus)
        }
        
        public func add(type: UserNotificationType, at: DateComponents?, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
            notificationType = type
            triggerAt = at
        }
        
        func removePending(type: UserNotificationType) {
            triggerAt = nil
            notificationType = nil
        }
        
    }
    
}
