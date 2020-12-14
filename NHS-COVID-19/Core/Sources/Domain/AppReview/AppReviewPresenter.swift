//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

#warning("Create an interface for this type")
// Using this type directly has some not-so-good side-effects. Specifically:
// * We have to make the type public
// * Using this type directly makes testing harder (e.g. we can't make `checkInsStore` non-optional without touching
//   unrelated test files.
public class AppReviewPresenter {
    private static let checkInCountThreshold = 2
    private let checkInsStore: CheckInsStore?
    private let reviewController: StoreReviewControlling
    private let currentDateProvider: DateProviding
    
    public var presentReview: () -> Void {
        return {
            if self.uniqueDayCheckIns.count == Self.checkInCountThreshold, self.firstCheckInToday {
                self.reviewController.requestAppReview()
            }
        }
    }
    
    private var uniqueDayCheckIns: Set<LocalDay> {
        return Set(checkInLocalDays)
    }
    
    private var checkInLocalDays: [LocalDay] {
        guard let checkInsStore = checkInsStore else { return [] }
        return (checkInsStore.load() ?? []).map { LocalDay(gregorianDay: $0.checkedIn.day, timeZone: .current) }
    }
    
    private var firstCheckInToday: Bool {
        let today = currentDateProvider.currentLocalDay
        return checkInLocalDays.filter { today == $0 }.count == 1
    }
    
    public init(checkInsStore: CheckInsStore?, reviewController: StoreReviewControlling, currentDateProvider: DateProviding) {
        self.checkInsStore = checkInsStore
        self.reviewController = reviewController
        self.currentDateProvider = currentDateProvider
    }
}
