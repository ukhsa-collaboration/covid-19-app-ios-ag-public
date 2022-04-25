//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Scenarios
import TestSupport
import XCTest
@testable import Domain

extension IsolationLogicalState: TestProp {
    public struct Configuration: TestPropConfiguration {
        var today = LocalDay.today
        lazy var selfDiagnosisDay = today.gregorianDay
        var isolationInfo = IsolationInfo(indexCaseInfo: nil, contactCaseInfo: nil)
        var isolationConfiguration = IsolationConfiguration(
            maxIsolation: 21,
            contactCase: 14,
            indexCaseSinceSelfDiagnosisOnset: 8,
            indexCaseSinceSelfDiagnosisUnknownOnset: 9,
            housekeepingDeletionPeriod: 14,
            indexCaseSinceNPEXDayNoSelfDiagnosis: 11,
            testResultPollingTokenRetentionPeriod: 28
        )
        
        public init() {}
    }
    
    public init(configuration: Configuration) {
        self.init(
            today: configuration.today,
            info: configuration.isolationInfo,
            configuration: configuration.isolationConfiguration
        )
    }
}

class IsolationLogicalStateTests: XCTestCase {
    
    @Propped
    private var state: IsolationLogicalState
    
    // MARK: Not isolating
    
    func testEmptyIsolationInfo() {
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))
    }
    
    // MARK: Isolation duration calculation
    
    func testEmptyIndexCaseInfo() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 9)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testIndexCaseNegativeTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: nil), contactCaseInfo: nil)))
    }
    
    func testIndexCasePositiveTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 9)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testIndexCaseNegativeTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: nil), contactCaseInfo: nil)))
    }
    
    func testIndexCasePositiveTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testIndexCaseNoTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationNoOnsetDay() {
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisUnknownOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testContactCase() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    func testContactCaseIsolationPeriodNotGreaterThanConfigurationMaxIsolation() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationConfiguration.contactCase = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    // MARK: Financial Support
    
    func testCannotApplyFinancialSupportWhenNotIsolating() {
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testCannotApplyFinancialSupportWhenIsolationExceeded() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -14)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testCannotApplyFinancialSupportWhenItsAnIndexCase() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testisInCorrectIsolationStateToApplyForFinancialSupportWhenItsAContactCase() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        XCTAssertTrue(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testisInCorrectIsolationStateToApplyForFinancialSupportWhenItsBothCases() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        XCTAssertTrue(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testisInCorrectIsolationStateToApplyForFinancialSupportWhenItsBothCasesAndPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    // MARK: Isolation has ended
    
    func testEndOfIsolationBeforeTodayDoesNotTriggerIsolation() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 10)
        
        let endDay = $state.today.advanced(by: -2)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: endDay, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolation() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: $state.today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil))))
    }
    
    func testEndOfIsolationBeforeTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 10)
        
        let endDay = $state.today.advanced(by: -2)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        
        let endDay = $state.today
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil))))
    }
    
    func testManualTestEntryTriggersIsolation() {
        let npexDay = LocalDay.today.advanced(by: -2)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            symptomaticInfo: nil,
            testInfo: .init(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: .today, testEndDay: npexDay.gregorianDay)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        XCTAssertEqual(state.isolation, Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: false, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testManualTestEntryWithOldTestDoesNotTriggerIsolation() {
        let npexDay = LocalDay.today.advanced(by: -12)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days

        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            symptomaticInfo: nil,
            testInfo: .init(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: .today, testEndDay: npexDay.gregorianDay)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: false, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil))))
    }
    
    // MARK: Interested in exposure notifications
    
    func testInterestedInExposureNotificationsTrueWhenNotIsolating() {
        let state: IsolationLogicalState = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        XCTAssertTrue(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromContactCase() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today)))
        
        XCTAssertFalse(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromBothCases() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(exposureDay: .today)))
        
        XCTAssertFalse(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsTrueWhenIsolatingFromIndexCaseWithPositiveTest() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: true, isPendingConfirmation: true), contactCaseInfo: nil))
        
        XCTAssertTrue(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromIndexCaseWithConfirmedPositiveTest() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        
        XCTAssertFalse(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsTrueWhenIsolatingFromIndexCaseWithNoPositiveTest() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        
        XCTAssertTrue(state.interestedInExposureNotifications)
    }
    
    func testManualEntryRequiresConfirmatoryTestWithOldTestDoesNotTriggerIsolation() {
        let npexDay = LocalDay.today.advanced(by: -12)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            symptomaticInfo: nil,
            testInfo: .init(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, shouldOfferFollowUpTest: true, receivedOnDay: .today, testEndDay: npexDay.gregorianDay)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: false, isPendingConfirmation: true, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil))))
    }
    
    func testManualTestEntryRequiresConfirmatoryTestTriggersIsolation() {
        let npexDay = LocalDay.today.advanced(by: -2)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            symptomaticInfo: nil,
            testInfo: .init(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, shouldOfferFollowUpTest: true, receivedOnDay: .today, testEndDay: npexDay.gregorianDay)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        XCTAssertEqual(state.isolation, Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: false, isPendingConfirmation: true, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: nil)))
    }
    
    func testIsIsolatingBecauseOfContactCaseEnteringPositiveRequiresConfirmatoryTestShouldBecomeBothCases() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        
        let npexDay = LocalDay.today.advanced(by: -3)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            symptomaticInfo: nil,
            testInfo: .init(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, shouldOfferFollowUpTest: true, receivedOnDay: .today, testEndDay: npexDay.gregorianDay)
        )
        
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        XCTAssertEqual(state.isolation, Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: false, isPendingConfirmation: true, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration), contactCaseInfo: .init(exposureDay: exposureDay))))
    }
    
    // MARK: Exposure notification processing behaviour
    
    func testExposureNotificationProcessingBehaviourIsNoneWhenIsolatingFromContactCase() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today)))
        
        XCTAssertEqual(state.exposureNotificationProcessingBehaviour, .doNotProcessExposures)
    }
    
    func testExposureNotificationProcessingBehaviourIsNoneWhenIsolatingFromConfirmedPositive() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: .init(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        
        XCTAssertEqual(state.exposureNotificationProcessingBehaviour, .doNotProcessExposures)
    }
    
    func testExposureNotificationProcessingBehaviourIsAllWhenIsolatingFromUnconfirmedTest() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: .init(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: true, isPendingConfirmation: true), contactCaseInfo: nil))
        
        XCTAssertEqual(state.exposureNotificationProcessingBehaviour, .allExposures)
    }
    
    func testExposureNotificationProcessingBehaviourSaysShouldHandleExposureWhenBehaviourIsAll() {
        let behaviour = ExposureNotificationProcessingBehaviour.allExposures
        XCTAssertTrue(behaviour.shouldNotifyForExposure(
            on: .today,
            currentDateProvider: MockDateProvider(),
            isolationLength: DayDuration(11)
        ))
    }
    
    func testExposureNotificationProcessingBehaviourSaysShouldHandleExposuresOnOrAfterDateWeOptedOutOfContactIsolation() {
        let behaviour = ExposureNotificationProcessingBehaviour.onlyProcessExposuresOnOrAfter(.today)
        XCTAssertFalse(behaviour.shouldNotifyForExposure(
            on: GregorianDay.today.advanced(by: -1),
            currentDateProvider: MockDateProvider(),
            isolationLength: DayDuration(11)
        ))
        XCTAssertFalse(behaviour.shouldNotifyForExposure(
            on: .today,
            currentDateProvider: MockDateProvider(),
            isolationLength: DayDuration(11)
        ))
        XCTAssertTrue(behaviour.shouldNotifyForExposure(
            on: GregorianDay.today.advanced(by: 1),
            currentDateProvider: MockDateProvider(),
            isolationLength: DayDuration(11)
        ))
    }
    
    func testExposureNotificationProcessingBehaviourSaysShouldNotHandleExposuresIfNotInterested() {
        let behaviour = ExposureNotificationProcessingBehaviour.doNotProcessExposures
        XCTAssertFalse(behaviour.shouldNotifyForExposure(
            on: .today,
            currentDateProvider: MockDateProvider(),
            isolationLength: DayDuration(11)
        ))
    }
    
    // MARK: Early release from isolation when person opts out of contact isolation
    
    // TODO: Write some more tests to cover successive isolations.
    
    func testReleasedFromIsolationWhenPersonOptsOutFromContactIsolation() {
        let exposureDay = GregorianDay.today.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, optOutOfIsolationDay: .today)
        let expected = Isolation(
            fromDay: .today,
            untilStartOfDay: LocalDay(gregorianDay: .today, timeZone: $state.today.timeZone),
            reason: Isolation.Reason(
                indexCaseInfo: nil,
                contactCaseInfo: .init(
                    exposureDay: exposureDay
                )
            ), optOutOfContactIsolationInfo: Isolation.OptOutOfContactIsolationInfo(
                optOutDay: .today,
                untilStartOfDay: LocalDay(gregorianDay: exposureDay + DayDuration(14), timeZone: .current)
            )
        )
        XCTAssertEqual(state.isolation, expected)
    }
}

private extension IsolationLogicalStateTests {
    func isolating(for reason: Isolation.Reason) -> IsolationLogicalState {
        .isolating(
            Isolation(fromDay: LocalDay.today.advanced(by: -2), untilStartOfDay: .today, reason: reason),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: reason.contactCaseInfo != nil ? true : false
        )
    }
}

private extension IndexCaseInfo {
    
    init(selfDiagnosisDay: GregorianDay, onsetDay: GregorianDay?, testResult: TestResult?) {
        self.init(
            symptomaticInfo: SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
            testInfo: testResult.map { TestInfo(result: $0, testKitType: .labResult, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: .today, testEndDay: nil) }
        )
    }
    
}
