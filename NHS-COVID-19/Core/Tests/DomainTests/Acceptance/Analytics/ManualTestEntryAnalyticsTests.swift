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
        advanceToEndOfAnalyticsWindow()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assert(\.isIsolatingBackgroundTick).isNotPresent()
        assert(\.isIsolatingForTestedPositiveBackgroundTick).isNotPresent()
        assert(\.hasTestedPositiveBackgroundTick).isNotPresent()
        
        // Enters positive test result on 2nd Jan
        // Isolation end date: 12th Jan
        try manualTestResultEntry.enterPositive()
        
        advanceToEndOfAnalyticsWindow()
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to positive test result
        assert(\.receivedPositiveTestResult).equals(1)
        assert(\.receivedPositiveTestResultEnteredManually).equals(1)
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.hasTestedPositiveBackgroundTick).isPresent()
        assert(\.isIsolatingForTestedPositiveBackgroundTick).isPresent()
        
        // Dates: 4th-13th Jan -> Analytics packets for: 3rd-12th Jan
        // Still in isolation
        for _ in 4 ... 13 {
            advanceToEndOfAnalyticsWindow()
            
            assert(\.receivedPositiveTestResult).isNotPresent()
            assert(\.receivedPositiveTestResultEnteredManually).isNotPresent()
            assert(\.isIsolatingBackgroundTick).isPresent()
            assert(\.isIsolatingForTestedPositiveBackgroundTick).isPresent()
            assert(\.hasTestedPositiveBackgroundTick).isPresent()
        }
        
        // Dates: 13th-27th Jan -> Analytics packets for: 12th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        for _ in 14 ... 27 {
            advanceToEndOfAnalyticsWindow()
            
            assert(\.isIsolatingBackgroundTick).isNotPresent()
            assert(\.isIsolatingForTestedPositiveBackgroundTick).isNotPresent()
            assert(\.hasTestedPositiveBackgroundTick).isPresent()
        }
        
        advanceToEndOfAnalyticsWindow()
        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assert(\.hasTestedPositiveBackgroundTick).isNotPresent()
    }
    
    func testManuallyEnteredNegativeTestResult() throws {
        try manualTestResultEntry.enterNegative()
        
        advanceToEndOfAnalyticsWindow()
        
        assert(\.receivedNegativeTestResult).equals(1)
        assert(\.receivedNegativeTestResultEnteredManually).equals(1)
        
        advanceToEndOfAnalyticsWindow()
        
        assert(\.receivedNegativeTestResult).isNotPresent()
        assert(\.receivedNegativeTestResultEnteredManually).isNotPresent()
    }
    
    func testManuallyEnteredVoidTestResult() throws {
        try manualTestResultEntry.enterVoid()
        
        advanceToEndOfAnalyticsWindow()
        
        assert(\.receivedVoidTestResult).equals(1)
        assert(\.receivedVoidTestResultEnteredManually).equals(1)
        
        advanceToEndOfAnalyticsWindow()
        
        assert(\.receivedVoidTestResult).isNotPresent()
        assert(\.receivedVoidTestResultEnteredManually).isNotPresent()
    }
}
