//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class IndexCaseInfoTests: XCTestCase {
    func testAssumedOnsetDayReturnsOnsetDayWhenPresent() {
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))
        let selfDiagnosisDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))

        let info = IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
            testInfo: nil
        )

        XCTAssertEqual(info.symptomaticInfo?.assumedOnsetDay, onsetDay)
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, onsetDay)
    }

    func testAssumedOnsetDayReturnsTwoDaysBeforeSelfDiagnosisDayWhenOnsetDayNotPresent() {
        let selfDiagnosisDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))

        let info = IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: nil),
            testInfo: nil
        )

        let expectedOnsetDay = selfDiagnosisDay.advanced(by: -2)
        XCTAssertEqual(info.symptomaticInfo?.assumedOnsetDay, expectedOnsetDay)
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, expectedOnsetDay)
    }

    func testAssumedOnsetDayReturnsThreeDaysBeforeTestResultDayWhenOnsetDayNotPresent() {
        let manualTestEntryDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))

        let info = IndexCaseInfo(
            symptomaticInfo: nil,
            testInfo: .init(result: .positive, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: manualTestEntryDay, testEndDay: manualTestEntryDay)
        )

        let expectedOnsetDay = manualTestEntryDay
        XCTAssertNil(info.symptomaticInfo?.assumedOnsetDay)
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, expectedOnsetDay)
    }

    func testAssumedOnsetDayReturnsThreeDaysBeforeTestResultDayWhenOnsetDayIsNewer() {
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 9))
        let manualTestEntryDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))

        let info = IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: onsetDay, onsetDay: onsetDay),
            testInfo: .init(result: .positive, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: manualTestEntryDay, testEndDay: manualTestEntryDay)
        )

        let expectedOnsetDay = manualTestEntryDay
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, expectedOnsetDay)
    }

    func testAssumedOnsetDayReturnsThreeDaysBeforeTestResultDayWhenTwoDaysBeforeSelfDiagnosisDayIsNewer() {
        let selfDiagnosisDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 10))
        let manualTestEntryDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))

        let info = IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: nil),
            testInfo: .init(result: .positive, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: manualTestEntryDay, testEndDay: manualTestEntryDay)
        )

        let expectedOnsetDay = manualTestEntryDay
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, expectedOnsetDay)
    }

    func testAssumedOnsetDayReturnsOnsetDayWhenTestEndDayAndOnsetDayOnSameDay() {
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 9))
        let manualTestEntryDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 9))

        let info = IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: onsetDay, onsetDay: onsetDay),
            testInfo: .init(result: .positive, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: manualTestEntryDay, testEndDay: manualTestEntryDay)
        )

        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, onsetDay)
    }

    func testAssumedOnsetDayReturnsTwoDaysBeforeSelfDiagnosisWhenTestEndDayAndTwoDaysBeforeSelfDiagnosisOnSameDay() {
        let selfDiagnosisDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 11))
        let manualTestEntryDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 9))

        let info = IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: nil),
            testInfo: .init(result: .positive, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: manualTestEntryDay, testEndDay: manualTestEntryDay)
        )

        let expectedOnsetDay = selfDiagnosisDay.advanced(by: -2)
        XCTAssertEqual(info.assumedOnsetDayForExposureKeys, expectedOnsetDay)
    }
}
