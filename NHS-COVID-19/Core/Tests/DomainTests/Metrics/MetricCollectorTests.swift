//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import TestSupport
import XCTest
@testable import Domain

class MetricCollectorTests: XCTestCase {
    
    private var date = Date()
    private var store: MockEncryptedStore!
    private var collector: MetricCollector!
    
    override func setUp() {
        store = MockEncryptedStore()
        
        collector = MetricCollector(encryptedStore: store) { [weak self] in
            self!.date
        }
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
        """.narmalizedJSON()
        
        TS.assert(actual, equals: expected)
        
    }
    
    func testStoringASecondMetric() {
        
        store.stored["metrics"] = """
        {
            "entries": [
                { "name": "checkedIn", "date": 1000 }
            ]
        }
        """.narmalizedJSON()
        
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
        """.narmalizedJSON()
        
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
        """.narmalizedJSON()
        
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
        """.narmalizedJSON()
        
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
            ]
        }
        """.narmalizedJSON()
        
        let interval = DateInterval(
            start: Date(timeIntervalSinceReferenceDate: 2000),
            end: Date(timeIntervalSinceReferenceDate: 3000)
        )
        
        let actual = collector.recordedMetrics(in: interval)
        
        let expected: [Metric: Int] = [
            .deletedLastCheckIn: 3,
            .completedOnboarding: 1,
            .receivedPositiveTestResult: 1,
        ]
        
        TS.assert(actual, equals: expected)
        
    }
    
}
