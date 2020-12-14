//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class AppReviewPresenterTests: XCTestCase {
    private var storeReviewController: MockStoreReviewController!
    private var checkInsStore: CheckInsStore!
    private var appReviewPresenter: AppReviewPresenter!
    private var currentDate: UTCHour!
    
    override func setUp() {
        storeReviewController = MockStoreReviewController()
        checkInsStore = CheckInsStore(store: MockEncryptedStore(), venueDecoder: .forTests)
        currentDate = UTCHour(year: 2020, month: 5, day: 15, hour: 10)
        appReviewPresenter = AppReviewPresenter(
            checkInsStore: checkInsStore,
            reviewController: storeReviewController,
            currentDateProvider: MockDateProvider { self.currentDate.date }
        )
    }
    
    func testOnlyOneCheckIn() throws {
        let hour = currentDate.date
        let c1 = CheckIn(venue: .random(), checkedInDate: hour, isRisky: false)
        
        checkInsStore.save(c1)
        
        appReviewPresenter.presentReview()
        
        XCTAssertFalse(storeReviewController.requestedReview)
    }
    
    func testTwoCheckInsButSameDay() throws {
        let hour = currentDate.date
        
        let c1 = CheckIn(venue: .random(), checkedInDate: hour, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: hour, isRisky: false)
        
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        
        appReviewPresenter.presentReview()
        
        XCTAssertFalse(storeReviewController.requestedReview)
    }
    
    func testTwoCheckInsButNoNewCheckInDay() throws {
        let hour1 = currentDate.date.hoursAgo(2)
        let hour2 = currentDate.date
        
        let c1 = CheckIn(venue: .random(), checkedInDate: hour1, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: hour2, isRisky: false)
        
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        
        appReviewPresenter.presentReview()
        
        XCTAssertFalse(storeReviewController.requestedReview)
    }
    
    func testTwoCheckInsDifferentDay() throws {
        let hour1 = currentDate.date.hoursAgo(24)
        let hour2 = currentDate.date
        
        let c1 = CheckIn(venue: .random(), checkedInDate: hour1, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: hour2, isRisky: false)
        
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        
        appReviewPresenter.presentReview()
        
        XCTAssertTrue(storeReviewController.requestedReview)
    }
    
    func testSecondCheckInSameDay() throws {
        let hour1 = currentDate.date.hoursAgo(60 * 24) // removes 24 hours
        let hour2 = currentDate.date
        
        let c1 = CheckIn(venue: .random(), checkedInDate: hour1.hoursAgo(1), isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: hour2.hoursAgo(2), isRisky: false)
        let c3 = CheckIn(venue: .random(), checkedInDate: hour2.hoursAgo(1), isRisky: false)
        
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        
        appReviewPresenter.presentReview()
        
        XCTAssertFalse(storeReviewController.requestedReview)
    }
}
