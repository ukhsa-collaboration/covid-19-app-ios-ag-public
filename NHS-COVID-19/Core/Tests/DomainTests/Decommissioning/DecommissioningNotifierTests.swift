//
// Copyright © 2023 DHSC. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class DecommissioningNotifierTests: XCTestCase {

    private var notificationManager: MockUserNotificationsManager!
    private var notifier: DecommissioningNotifier!

    override func setUp() {
        super.setUp()

        notificationManager = MockUserNotificationsManager()
        notifier = DecommissioningNotifier(notificationManager: notificationManager)

        UserDefaults.standard.set(nil, forKey: notifier.key)
    }

    override func tearDown() {
        UserDefaults.standard.set(nil, forKey: notifier.key)
    }

    func testNotificationScheduled() {
        notifier.alertUser()
        XCTAssert(notificationManager.notificationType == .decommissioning)
    }

    func testNotificationNotScheduledSecondTime() {
        UserDefaults.standard.set(true, forKey: notifier.key)
        notifier.alertUser()
        XCTAssertNil(notificationManager.notificationType)
    }
}
