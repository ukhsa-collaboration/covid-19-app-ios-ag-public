//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import XCTest
@testable import Domain
@testable import Scenarios

class ExposureKeySharerResultTests: XCTestCase {
    func testKeysSentWithFlowTypeInitial() {
        let acknowledgementTime = UTCHour(year: 2021, month: 1, day: 1, hour: 5)
        let keySharingTime = UTCHour(year: 2021, month: 1, day: 2, hour: 4)
        let currentDateProvider = MockDateProvider { keySharingTime.date }
        let keySharerResult = ExposureKeysManager.KeySharerResult(
            result: .sent,
            flowType: .initial,
            acknowledgementTime: acknowledgementTime.date,
            currentDateProvider: currentDateProvider
        )
        XCTAssertEqual(keySharerResult, .markToDelete)
    }
    
    func testKeysSentWithFlowTypeReminder() {
        let acknowledgementTime = UTCHour(year: 2021, month: 1, day: 1, hour: 5)
        let keySharingTime = UTCHour(year: 2021, month: 1, day: 2, hour: 4)
        let currentDateProvider = MockDateProvider { keySharingTime.date }
        let keySharerResult = ExposureKeysManager.KeySharerResult(
            result: .sent,
            flowType: .reminder,
            acknowledgementTime: acknowledgementTime.date,
            currentDateProvider: currentDateProvider
        )
        XCTAssertEqual(keySharerResult, .markToDelete)
    }
    
    func testKeysNotSentWithFlowTypeReminder() {
        let acknowledgementTime = UTCHour(year: 2021, month: 1, day: 1, hour: 5)
        let keySharingTime = UTCHour(year: 2021, month: 1, day: 2, hour: 4)
        let currentDateProvider = MockDateProvider { keySharingTime.date }
        let keySharerResult = ExposureKeysManager.KeySharerResult(
            result: .notSent,
            flowType: .reminder,
            acknowledgementTime: acknowledgementTime.date,
            currentDateProvider: currentDateProvider
        )
        XCTAssertEqual(keySharerResult, .markToDelete)
    }
    
    func testKeysNotSentWithFlowTypeInitialMoreThan24HoursMarksToDelete() {
        let acknowledgementTime = UTCHour(year: 2021, month: 1, day: 1, hour: 5)
        let keySharingTime = UTCHour(year: 2021, month: 1, day: 2, hour: 6)
        let currentDateProvider = MockDateProvider { keySharingTime.date }
        let keySharerResult = ExposureKeysManager.KeySharerResult(
            result: .notSent,
            flowType: .initial,
            acknowledgementTime: acknowledgementTime.date,
            currentDateProvider: currentDateProvider
        )
        XCTAssertEqual(keySharerResult, .markToDelete)
    }
    
    func testKeysNotSentWithFlowTypeInitialEqualTo24HoursMarksFlowComplete() {
        let acknowledgementTime = UTCHour(year: 2021, month: 1, day: 1, hour: 5)
        let keySharingTime = UTCHour(year: 2021, month: 1, day: 2, hour: 5)
        let currentDateProvider = MockDateProvider { keySharingTime.date }
        let keySharerResult = ExposureKeysManager.KeySharerResult(
            result: .notSent,
            flowType: .initial,
            acknowledgementTime: acknowledgementTime.date,
            currentDateProvider: currentDateProvider
        )
        XCTAssertEqual(keySharerResult, .markInitialFlowComplete)
    }
    
    func testKeysNotSentWithFlowTypeInitialLessThan24HoursMarksFlowComplete() {
        let acknowledgementTime = UTCHour(year: 2021, month: 1, day: 1, hour: 5)
        let keySharingTime = UTCHour(year: 2021, month: 1, day: 2, hour: 4)
        let currentDateProvider = MockDateProvider { keySharingTime.date }
        let keySharerResult = ExposureKeysManager.KeySharerResult(
            result: .notSent,
            flowType: .initial,
            acknowledgementTime: acknowledgementTime.date,
            currentDateProvider: currentDateProvider
        )
        XCTAssertEqual(keySharerResult, .markInitialFlowComplete)
    }
}
