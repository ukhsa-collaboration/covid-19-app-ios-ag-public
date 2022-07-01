//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public protocol AppReviewPresenting {
    func presentReview()
}

class AppReviewPresenter: AppReviewPresenting {
    private static let checkInCountThreshold = 2

    private let checkInsStore: CheckInsStore
    private let reviewController: StoreReviewControlling
    private let currentDateProvider: DateProviding

    public func presentReview() {
        if uniqueDayCheckIns.count == Self.checkInCountThreshold, firstCheckInToday {
            reviewController.requestAppReview()
        }
    }

    private var uniqueDayCheckIns: Set<LocalDay> {
        return Set(checkInLocalDays)
    }

    private var checkInLocalDays: [LocalDay] {
        return (checkInsStore.load() ?? []).map { LocalDay(gregorianDay: $0.checkedIn.day, timeZone: .current) }
    }

    private var firstCheckInToday: Bool {
        let today = currentDateProvider.currentLocalDay
        return checkInLocalDays.filter { today == $0 }.count == 1
    }

    public init(checkInsStore: CheckInsStore, reviewController: StoreReviewControlling, currentDateProvider: DateProviding) {
        self.checkInsStore = checkInsStore
        self.reviewController = reviewController
        self.currentDateProvider = currentDateProvider
    }
}
