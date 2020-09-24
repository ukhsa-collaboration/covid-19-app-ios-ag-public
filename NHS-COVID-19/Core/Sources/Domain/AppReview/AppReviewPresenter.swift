//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public class AppReviewPresenter {
    private static let checkInCountThreshold = 2
    private let checkInsStore: CheckInsStore?
    private let reviewController: StoreReviewControlling
    private let currentDateProvider: () -> Date
    
    public var presentReview: () -> Void {
        return {
            let uniqueDayCheckIns = self.uniqueDayCheckIns.count
            let uniqueDayCheckIns2 = self.uniqueDayCheckIns
            if uniqueDayCheckIns == Self.checkInCountThreshold, self.firstCheckInToday {
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
        let today = LocalDay(date: currentDateProvider(), timeZone: .current)
        return checkInLocalDays.filter { today == $0 }.count == 1
    }
    
    public init(checkInsStore: CheckInsStore?, reviewController: StoreReviewControlling, currentDateProvider: @escaping () -> Date) {
        self.checkInsStore = checkInsStore
        self.reviewController = reviewController
        self.currentDateProvider = currentDateProvider
    }
}
