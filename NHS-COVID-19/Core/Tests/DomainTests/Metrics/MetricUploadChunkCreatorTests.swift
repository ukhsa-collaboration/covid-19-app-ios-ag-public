//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class MetricUploadChunkCreatorTests: XCTestCase {
    private var currentDate: Date!
    private var collector: MetricCollector!
    private var creator: MetricUploadChunkCreator!
    private static let appVersion = "3.0.0"
    
    override func setUp() {
        currentDate = Date()
        let currentDateProvider = MockDateProvider { self.currentDate }
        collector = MetricCollector(encryptedStore: MockEncryptedStore(), currentDateProvider: currentDateProvider)
        creator = MetricUploadChunkCreator(
            collector: collector,
            appInfo: AppInfo(bundleId: .random(), version: Self.appVersion, buildNumber: "1"),
            getPostcode: { String.random() },
            getLocalAuthority: { String.random() },
            currentDateProvider: currentDateProvider
        )
    }
    
    func testNextWindow() throws {
        let currentDay = GregorianDay(year: 2020, month: 10, day: 2)
        
        let entryDate = UTCHour(day: currentDay, hour: 11, minutes: 30)
        currentDate = entryDate.date
        collector.record(.checkedIn)
        
        currentDate = UTCHour(day: currentDay.advanced(by: 1), hour: 12, minutes: 50).date
        let metricInfo = try XCTUnwrap(creator.consumeMetricsInfoForNextWindow())
        
        let startDate = UTCHour(day: currentDay, hour: 0).date
        let endDate = UTCHour(day: currentDay.advanced(by: 1), hour: 0).date
        
        if case .triggeredPayload(let payload) = metricInfo.payload {
            XCTAssertEqual(payload.startDate, startDate)
            XCTAssertEqual(payload.endDate, endDate)
        } else {
            XCTFail()
        }
        XCTAssertEqual(metricInfo.recordedMetrics[.checkedIn], 1)
    }
    
    func testTwoWindows() throws {
        let currentDay = GregorianDay(year: 2020, month: 10, day: 2)
        
        currentDate = UTCHour(day: currentDay, hour: 5, minutes: 30).date
        collector.record(.completedOnboarding)
        
        currentDate = UTCHour(day: currentDay.advanced(by: 1), hour: 11, minutes: 30).date
        collector.record(.checkedIn)
        
        currentDate = UTCHour(day: currentDay.advanced(by: 2), hour: 12, minutes: 50).date
        let metricInfo1 = try XCTUnwrap(creator.consumeMetricsInfoForNextWindow())
        
        let startDate1 = UTCHour(day: currentDay, hour: 0).date
        let endDate1 = UTCHour(day: currentDay.advanced(by: 1), hour: 0).date
        
        if case .triggeredPayload(let payload) = metricInfo1.payload {
            XCTAssertEqual(payload.startDate, startDate1)
            XCTAssertEqual(payload.endDate, endDate1)
        } else {
            XCTFail()
        }
        XCTAssertEqual(metricInfo1.recordedMetrics[.completedOnboarding], 1)
        XCTAssertNil(metricInfo1.recordedMetrics[.checkedIn])
        
        let metricInfo2 = try XCTUnwrap(creator.consumeMetricsInfoForNextWindow())
        
        let startDate2 = UTCHour(day: currentDay.advanced(by: 1), hour: 0).date
        let endDate2 = UTCHour(day: currentDay.advanced(by: 2), hour: 0).date
        
        if case .triggeredPayload(let payload) = metricInfo2.payload {
            XCTAssertEqual(payload.startDate, startDate2)
            XCTAssertEqual(payload.endDate, endDate2)
        } else {
            XCTFail()
        }
        XCTAssertNil(metricInfo2.recordedMetrics[.completedOnboarding])
        XCTAssertEqual(metricInfo2.recordedMetrics[.checkedIn], 1)
    }
    
    func testEntryInCurrentWindow() throws {
        let currentDay = GregorianDay(year: 2020, month: 10, day: 2)
        
        let entryDate = UTCHour(day: currentDay, hour: 10, minutes: 30)
        currentDate = entryDate.date
        collector.record(.checkedIn)
        
        currentDate = UTCHour(day: currentDay, hour: 11, minutes: 50).date
        let metricInfo = creator.consumeMetricsInfoForNextWindow()
        
        XCTAssertNil(metricInfo)
    }
    
    func testNoEntries() throws {
        let metricInfo = creator.consumeMetricsInfoForNextWindow()
        
        XCTAssertNil(metricInfo)
    }
}
