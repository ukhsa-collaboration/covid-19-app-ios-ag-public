//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
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
}
