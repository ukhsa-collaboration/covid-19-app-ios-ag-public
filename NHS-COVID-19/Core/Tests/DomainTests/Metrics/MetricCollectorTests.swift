//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import TestSupport
import Combine
import XCTest
@testable import Domain

class MetricCollectorTests: XCTestCase {
    
    private var date = Date()
    private var store: MockEncryptedStore!
    private var collector: MetricCollector!
    private var enabled: MetricsState!

    override func setUp() {
        store = MockEncryptedStore()
        
        enabled = MetricsState()

        enabled.set(rawState: RawState.onboardedRawState.domainProperty())
        
        let currentDateProvider = MockDateProvider { [weak self] in
            self!.date
        }
        collector = MetricCollector(encryptedStore: store, currentDateProvider: currentDateProvider, enabled: enabled)
    }
    
    func testStoringMetrics() {
        
        date = Date(timeIntervalSinceReferenceDate: 1000)
        collector.record(.checkedIn)
        
        let actual = store.stored["metrics"]?.normalizingJSON()
        
        let expected = """
        {
            "entries": [
                { "name": "checkedIn", "date": 1000 }
            ]
        }
        """.normalizedJSON()
        
        TS.assert(actual, equals: expected)
        
    }
    
    func testNotStoringMetricsWhenDisabled() {

        enabled.set(rawState: RawState.notOnboardedRawState.domainProperty())

        date = Date(timeIntervalSinceReferenceDate: 1000)
        collector.record(.runningNormallyTick)
        collector.record(.runningNormallyTick)
        collector.record(.contactCaseBackgroundTick)
        
        let actual = store.stored["metrics"]?.normalizingJSON()

        XCTAssertNil(actual)
    }
    
    func testStoringASecondMetric() {
        
        store.stored["metrics"] = """
        {
            "entries": [
                { "name": "checkedIn", "date": 1000 }
            ]
        }
        """.normalizedJSON()
        
        date = Date(timeIntervalSinceReferenceDate: 2000)
        collector.record(.deletedLastCheckIn)
        
        let actual = store.stored["metrics"]?.normalizingJSON()
        
        let expected = """
        {
            "entries": [
                { "name": "checkedIn", "date": 1000 },
                { "name": "deletedLastCheckIn", "date": 2000 },
            ]
        }
        """.normalizedJSON()
        
        TS.assert(actual, equals: expected)
        
    }
    
    func testDeletingOldMetrics() {
        
        store.stored["metrics"] = """
        {
            "entries": [
                { "name": "checkedIn", "date": 1000 },
                { "name": "deletedLastCheckIn", "date": 1999 },
                { "name": "deletedLastCheckIn", "date": 2000 },
                { "name": "deletedLastCheckIn", "date": 2001 },
                { "name": "deletedLastCheckIn", "date": 3000 },
            ]
        }
        """.normalizedJSON()
        
        date = Date(timeIntervalSinceReferenceDate: 2000)
        collector.consumeMetrics(notAfter: date)
        
        let actual = store.stored["metrics"]?.normalizingJSON()
        
        let expected = """
        {
            "entries": [
            { "name": "deletedLastCheckIn", "date": 2001 },
            { "name": "deletedLastCheckIn", "date": 3000 },
            ],
            "latestWindowEnd": 2000
        }
        """.normalizedJSON()
        
        TS.assert(actual, equals: expected)
        
    }
    
    func testGettingCountOfRecordedMetrics() {
        
        store.stored["metrics"] = """
        {
            "entries": [
                { "name": "checkedIn", "date": 1000 },
                { "name": "deletedLastCheckIn", "date": 1999 },
        
                { "name": "completedOnboarding", "date": 2000 },
                { "name": "deletedLastCheckIn", "date": 2000 },
                { "name": "deletedLastCheckIn", "date": 2500 },
                { "name": "deletedLastCheckIn", "date": 3000 },
                { "name": "receivedPositiveTestResult", "date": 3000 },
                { "name": "receivedNegativeTestResult", "date": 3001 },
                { "name": "totalExposureWindowsConsideredRisky", "date": 2500 },
                { "name": "totalExposureWindowsConsideredRisky", "date": 2300 },
                { "name": "totalExposureWindowsNotConsideredRisky", "date": 2400 },
                { "name": "totalExposureWindowsNotConsideredRisky", "date": 2100 },
                { "name": "totalExposureWindowsNotConsideredRisky", "date": 2800 },
        
            ]
        }
        """.normalizedJSON()
        
        let interval = DateInterval(
            start: Date(timeIntervalSinceReferenceDate: 2000),
            end: Date(timeIntervalSinceReferenceDate: 3000)
        )
        
        let actual = collector.recordedMetrics(in: interval)
        
        let expected: [Metric: Int] = [
            .deletedLastCheckIn: 3,
            .completedOnboarding: 1,
            .receivedPositiveTestResult: 1,
            .totalExposureWindowsConsideredRisky: 2,
            .totalExposureWindowsNotConsideredRisky: 3,
        ]
        
        TS.assert(actual, equals: expected)
        
    }
    
    func testDeletingRecordedMetrics() {
        
        testStoringASecondMetric()
        
        let actualBefore = store.stored["metrics"]
        XCTAssertNotNil(actualBefore)

        collector.delete()
        
        let actualAfter = store.stored["metrics"]?.normalizingJSON()
        XCTAssertNil(actualAfter)
    }

  func testGettingCountOfLFDRecordedMetric() {
        store.stored["metrics"] = """
        {
            "entries": [
                { "name": "receivedPositiveLFDTestResultViaPolling", "date": 2800 },
                { "name": "receivedNegativeLFDTestResultViaPolling", "date": 2800 },
                { "name": "receivedVoidLFDTestResultViaPolling", "date": 2800 },
                { "name": "receivedVoidLFDTestResultViaPolling", "date": 2500 },
                { "name": "receivedPositiveLFDTestResultEnteredManually", "date": 2800 },
                { "name": "receivedNegativeLFDTestResultEnteredManually", "date": 2800 },
                { "name": "receivedVoidLFDTestResultEnteredManually", "date": 2800 },
            ]
        }
        """.normalizedJSON()
        
        let interval = DateInterval(
            start: Date(timeIntervalSinceReferenceDate: 2000),
            end: Date(timeIntervalSinceReferenceDate: 3000)
        )
        
        let actual = collector.recordedMetrics(in: interval)
        
        let expected: [Metric: Int] = [
            .receivedPositiveLFDTestResultViaPolling: 1,
            .receivedNegativeLFDTestResultViaPolling: 1,
            .receivedVoidLFDTestResultViaPolling: 2,
            .receivedPositiveLFDTestResultEnteredManually: 1,
            .receivedNegativeLFDTestResultEnteredManually: 1,
            .receivedVoidLFDTestResultEnteredManually: 1,
        ]
        
        TS.assert(actual, equals: expected)
    }
    
}
