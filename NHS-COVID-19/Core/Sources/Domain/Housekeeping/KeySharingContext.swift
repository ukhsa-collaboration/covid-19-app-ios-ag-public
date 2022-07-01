//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging

class KeySharingContext {
    private static let logger = Logger(label: "KeySharingHousekeeper")

    private let currentDateProvider: DateProviding
    private let contactCaseIsolationDuration: DayDuration
    private let onsetDay: () -> GregorianDay?
    private let keySharingStore: KeySharingStore
    private var userNotificationManager: UserNotificationManaging

    init(currentDateProvider: DateProviding,
         contactCaseIsolationDuration: DayDuration,
         onsetDay: @escaping () -> GregorianDay?,
         keySharingStore: KeySharingStore,
         userNotificationManager: UserNotificationManaging) {
        self.currentDateProvider = currentDateProvider
        self.contactCaseIsolationDuration = contactCaseIsolationDuration
        self.onsetDay = onsetDay
        self.keySharingStore = keySharingStore
        self.userNotificationManager = userNotificationManager
    }

    private func isDaysOfInterestEmpty() -> Bool {
        guard let onsetDay = self.onsetDay(), let testAcknowledgementDay = keySharingStore.info.currentValue?.testResultAcknowledgmentTime.day else {
            return true
        }

        let infectiousDateRange = TemporaryExposureKey.infectiousDateRange(onsetDay: onsetDay)
        let interestingDateRange = TemporaryExposureKey.dateRangeConsideredForUploadIgnoringInfectiousness(
            acknowledgmentDay: testAcknowledgementDay,
            isolationDuration: contactCaseIsolationDuration,
            today: currentDateProvider.currentGregorianDay(timeZone: .current)
        )

        let daysOfInterest = infectiousDateRange.clamped(to: interestingDateRange)

        return daysOfInterest.isEmpty
    }

    func executeHouseKeeper() -> AnyPublisher<Void, Never> {
        Self.logger.debug("execute housekeeping for KeySharingInfo")

        if isDaysOfInterestEmpty() {
            Self.logger.debug("no days of interest left - deleting KeySharingInfo")
            keySharingStore.reset()
        }

        return Empty().eraseToAnyPublisher()
    }

    func showReminderNotificationIfNeeded() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in

            guard let keySharingInfo = self.keySharingStore.info.currentValue else {
                promise(.success(()))
                return
            }

            guard !keySharingInfo.hasTriggeredReminderNotification else {
                return
            }

            guard UTCHour(containing: self.currentDateProvider.currentDate).isLaterThanOrEqualTo(hours: 24, after: keySharingInfo.testResultAcknowledgmentTime) else {
                promise(.success(()))
                return
            }

            guard !self.isDaysOfInterestEmpty() else {
                promise(.success(()))
                return
            }

            self.userNotificationManager.add(type: .shareKeysReminder, at: nil, withCompletionHandler: nil)
            Metrics.signpost(.totalShareExposureKeysReminderNotifications)

            self.keySharingStore.didTriggerReminderNotification()

            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}
