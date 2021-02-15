//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class ManualTestEntryAnalyticsTests: AnalyticsTests {
    private var manualTestResultEntry: ManualTestResultEntry!
    
    override func setUpFunctionalities() {
        manualTestResultEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
    }
    
    // hasTestedPositiveBackgroundTick - Manual
    // >0 if the app is aware that the user has received/entered a positive test
    // this currently happens during an isolation and for the 14 days after isolation
    func testHasTestedPositiveBackgroundTickPresentAfterTestResultEntered() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        assertAnalyticsPacketIsNormal()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        
        // Enters positive test result on 2nd Jan
        // Isolation end date: 12th Jan
        try manualTestResultEntry.enterPositive()
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to positive test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultEnteredManually)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
        }
        
        // Dates: 4th-13th Jan -> Analytics packets for: 3rd-12th Jan
        // Still in isolation
        assertOnFieldsForDateRange(dateRange: 4 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
        }
        
        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
        }
        
        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }
    
    // hasTestedPositiveBackgroundTick - Manual
    // >0 if the app is aware that the user has received/entered a positive test
    // this currently happens during an isolation and for the 14 days after isolation
    func testHasTestedPositiveBackgroundTickPresentAfterUnconfirmedTestResultEntered() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        assertAnalyticsPacketIsNormal()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        
        // Enters positive test result on 2nd Jan
        // Isolation end date: 12th Jan
        try manualTestResultEntry.enterPositive(requiresConfirmatoryTest: true)
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to unconfirmed positive test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultEnteredManually)
            assertField.equals(expected: 1, \.receivedUnconfirmedPositiveTestResult)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForUnconfirmedTestBackgroundTick)
        }
        
        // Current date: 4th Jan -> Analytics packet for: 3nd Jan
        // Now in isolation due to unconfirmed positive test result
        assertOnFields { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForUnconfirmedTestBackgroundTick)
        }
        
        // Enters a confirmatory positive test result
        // Isolation end date will not change: 12th Jan
        try manualTestResultEntry.enterPositive()
        
        // Current date: 5th Jan -> Analytics packet for: 4nd Jan
        // Now in isolation due to unconfirmed positive test result
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedPositiveTestResult)
            assertField.equals(expected: 1, \.receivedPositiveTestResultEnteredManually)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
        }
        
        // Dates: 6th-13th Jan -> Analytics packets for: 5rd-12th Jan
        // Still in isolation
        assertOnFieldsForDateRange(dateRange: 6 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForTestedPositiveBackgroundTick)
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
        }
        
        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isPresent(\.hasTestedPositiveBackgroundTick)
        }
        
        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }
    
    func testManuallyEnteredNegativeTestResult() throws {
        try manualTestResultEntry.enterNegative()
        
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedNegativeTestResult)
            assertField.equals(expected: 1, \.receivedNegativeTestResultEnteredManually)
        }
        
        assertAnalyticsPacketIsNormal()
    }
    
    func testManuallyEnteredVoidTestResult() throws {
        try manualTestResultEntry.enterVoid()
        
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.receivedVoidTestResult)
            assertField.equals(expected: 1, \.receivedVoidTestResultEnteredManually)
        }
        
        assertAnalyticsPacketIsNormal()
    }
}
