//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class IsolationPropertiesTests: XCTestCase {
    
    func testVaccineThresholdDate() {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: Isolation.Reason(
                indexCaseInfo: nil,
                contactCaseInfo: Isolation.ContactCaseInfo(exposureDay: .init(year: 2021, month: 7, day: 20))
            )
        )
        
        let expectedDate = GregorianDay(year: 2021, month: 7, day: 5).startDate(in: .current)
        XCTAssertEqual(isolation.vaccineThresholdDate, expectedDate)
    }
    
    func testBirthThresholdDateForEngland() {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: Isolation.Reason(
                indexCaseInfo: nil,
                contactCaseInfo: Isolation.ContactCaseInfo(exposureDay: .init(year: 2021, month: 8, day: 30))
            )
        )
        
        let expectedDate = GregorianDay(year: 2021, month: 2, day: 28).startDate(in: .current)
        XCTAssertEqual(isolation.birthThresholdDate(country: .england), expectedDate)
    }
    
    func testBirthThresholdDateForWales() {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: Isolation.Reason(
                indexCaseInfo: nil,
                contactCaseInfo: Isolation.ContactCaseInfo(exposureDay: .init(year: 2021, month: 8, day: 30))
            )
        )
        
        let expectedDate = GregorianDay(year: 2021, month: 8, day: 30).startDate(in: .current)
        XCTAssertEqual(isolation.birthThresholdDate(country: .wales), expectedDate)
    }
    
    func testSecondTestDateWithinLimit() {
        let encouterDate = GregorianDay(year: 2021, month: 9, day: 10)
        let dateProvider = MockDateProvider(getDate: {
            GregorianDay(year: 2021, month: 9, day: 15).startDate(in: .current)
        })
        let isolation = Isolation(
            fromDay: LocalDay(gregorianDay: encouterDate, timeZone: .current),
            untilStartOfDay: LocalDay(gregorianDay: encouterDate.advanced(by: 11), timeZone: .current),
            reason: Isolation.Reason(
                indexCaseInfo: nil,
                contactCaseInfo: Isolation.ContactCaseInfo(exposureDay: encouterDate)
            )
        )
        
        XCTAssertEqual(isolation.secondTestAdvice(dateProvider: dateProvider, country: .england), nil)
        let expectedDate = GregorianDay(year: 2021, month: 9, day: 18).startDate(in: .current)
        XCTAssertEqual(isolation.secondTestAdvice(dateProvider: dateProvider, country: .wales), expectedDate)
    }
    
    func testSecondTestDateOutsideLimit() {
        let encouterDate = GregorianDay(year: 2021, month: 9, day: 10)
        let dateProvider = MockDateProvider(getDate: {
            GregorianDay(year: 2021, month: 9, day: 16).startDate(in: .current)
        })
        let isolation = Isolation(
            fromDay: LocalDay(gregorianDay: encouterDate, timeZone: .current),
            untilStartOfDay: LocalDay(gregorianDay: encouterDate.advanced(by: 11), timeZone: .current),
            reason: Isolation.Reason(
                indexCaseInfo: nil,
                contactCaseInfo: Isolation.ContactCaseInfo(exposureDay: encouterDate)
            )
        )
        
        XCTAssertEqual(isolation.secondTestAdvice(dateProvider: dateProvider, country: .wales), nil)
        XCTAssertEqual(isolation.secondTestAdvice(dateProvider: dateProvider, country: .england), nil)
    }
}
