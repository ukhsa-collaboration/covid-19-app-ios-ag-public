//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class IsolationStateChangeNotifierTests: XCTestCase {

    private var subject: PassthroughSubject<IsolationLogicalState, Never>!
    private var notificationManager: MockUserNotificationsManager!
    private var notifier: IsolationStateChangeNotifier!

    override func setUp() {
        super.setUp()

        subject = PassthroughSubject()
        notificationManager = MockUserNotificationsManager()
        notifier = IsolationStateChangeNotifier(notificationManager: notificationManager)
    }

    func testNoNotificationScheduledWhenNoSignalSent() {
        let cancellable = notifier.alertUserToChanges(in: subject)
        defer { cancellable.cancel() }

        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(notificationManager.triggerAt)
    }

    func testNoNotificationScheduledWhenNotIsolatingSignalSent() {
        let cancellable = notifier.alertUserToChanges(in: subject)
        defer { cancellable.cancel() }

        subject.send(.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))

        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(notificationManager.triggerAt)
    }

    func testPendingNotificationsRemovedWhenNotIsolatingSignalSent() {
        let cancellable = notifier.alertUserToChanges(in: subject)
        defer { cancellable.cancel() }

        subject.send(.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))

        XCTAssertEqual(notificationManager.removePendingNotificationType, .isolationState)
    }

    func testPendingNotificationsRemovedWhenNotIsolatingButNotAcknowledgedSignalSent() {
        let cancellable = notifier.alertUserToChanges(in: subject)
        defer { cancellable.cancel() }

        subject.send(.isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today)))))

        XCTAssertEqual(notificationManager.removePendingNotificationType, .isolationState)
    }

    func testNotificationScheduledWhenNotIsolatingSignalSent() {
        let cancellable = notifier.alertUserToChanges(in: subject)
        defer { cancellable.cancel() }

        let day = GregorianDay(year: 2020, month: 5, day: 23)

        subject.send(.isolating(Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: day, timeZone: .current), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today))), endAcknowledged: false, startOfContactIsolationAcknowledged: true))

        let triggerAt = mutating(DateComponents()) {
            $0.year = 2020
            $0.month = 5
            $0.day = 22
            $0.hour = 21
        }

        XCTAssertEqual(notificationManager.notificationType, .isolationState)
        TS.assert(notificationManager.triggerAt, equals: triggerAt)
    }

    func testNotificationScheduledWhenNotIsolatingSignalSentChangesMonthAsExpected() {
        let cancellable = notifier.alertUserToChanges(in: subject)
        defer { cancellable.cancel() }

        let day = GregorianDay(year: 2020, month: 5, day: 1)

        subject.send(.isolating(Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: day, timeZone: .current), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today))), endAcknowledged: false, startOfContactIsolationAcknowledged: true))

        let triggerAt = mutating(DateComponents()) {
            $0.year = 2020
            $0.month = 4
            $0.day = 30
            $0.hour = 21
        }

        XCTAssertEqual(notificationManager.notificationType, .isolationState)
        TS.assert(notificationManager.triggerAt, equals: triggerAt)
    }

}
