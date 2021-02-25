//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class IndexCaseInfoTests: XCTestCase {
    func testAssumedOnsetDayReturnsOnsetDayWhenPresent() {
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))
        let selfDiagnosisDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))
        
        let info = IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: onsetDay,
            testInfo: nil
        )
        
        XCTAssertEqual(info.assumedOnsetDayForSelfDiagnosis, onsetDay)
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, onsetDay)
    }
    
    func testAssumedOnsetDayReturnsTwoDaysBeforeSelfDiagnosisDayWhenOnsetDayNotPresent() {
        let selfDiagnosisDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))
        
        let info = IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: nil,
            testInfo: nil
        )
        
        let expectedOnsetDay = selfDiagnosisDay.advanced(by: -2)
        XCTAssertEqual(info.assumedOnsetDayForSelfDiagnosis, expectedOnsetDay)
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, expectedOnsetDay)
    }
    
    func testAssumedOnsetDayReturnsThreeDaysBeforeTestResultDayWhenOnsetDayNotPresent() {
        let manualTestEntryDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))
        
        let info = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: manualTestEntryDay),
            onsetDay: nil,
            testInfo: nil
        )
        
        let expectedOnsetDay = manualTestEntryDay.advanced(by: -3)
        XCTAssertNil(info.assumedOnsetDayForSelfDiagnosis)
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, expectedOnsetDay)
    }
}
