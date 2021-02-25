//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
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
            indexCaseSinceNPEXDayNoSelfDiagnosis: IsolationConfiguration.default.indexCaseSinceNPEXDayNoSelfDiagnosis
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
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testIndexCaseNegativeTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testIndexCasePositiveTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 9)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testIndexCaseNegativeTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testIndexCasePositiveTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testIndexCaseNoTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationNoOnsetDay() {
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisUnknownOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testContactCase() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    func testContactCaseIsolationPeriodNotGreaterThanConfigurationMaxIsolation() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationConfiguration.contactCase = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil))))
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
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: endDay, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolation() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: $state.today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))))
    }
    
    func testEndOfIsolationBeforeTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 10)
        
        let endDay = $state.today.advanced(by: -2)
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        
        let endDay = $state.today
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))))
    }
    
    func testManualTestEntryTriggersIsolation() {
        let npexDay = LocalDay.today.advanced(by: -2)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: .today)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        XCTAssertEqual(state.isolation, Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: false, isPendingConfirmation: false), contactCaseInfo: nil)))
    }
    
    func testManualTestEntryWithVoidResultDoesNotTriggerIsolation() {
        let npexDay = LocalDay.today.advanced(by: -2)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .void, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: .today)
        )
        
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))
    }
    
    func testManualTestEntryWithOldTestDoesNotTriggerIsolation() {
        let npexDay = LocalDay.today.advanced(by: -12)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: .today)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: false, isPendingConfirmation: false), contactCaseInfo: nil))))
    }
    
    // MARK: Interested in exposure notifications
    
    func testInterestedInExposureNotificationsTrueWhenNotIsolating() {
        let state: IsolationLogicalState = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        XCTAssertTrue(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromContactCase() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil)))
        
        XCTAssertFalse(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromBothCases() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .labResult, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(optOutOfIsolationDay: nil)))
        
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
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: .today)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: false, isPendingConfirmation: true), contactCaseInfo: nil))))
    }
    
    func testManualTestEntryRequiresConfirmatoryTestTriggersIsolation() {
        let npexDay = LocalDay.today.advanced(by: -2)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: .today)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        
        XCTAssertEqual(state.isolation, Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: false, isPendingConfirmation: true), contactCaseInfo: nil)))
    }
    
    func testIsIsolatingBecauseOfContactCaseEnteringPositiveRequiresConfirmatoryTestShouldBecomeBothCases() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        
        let npexDay = LocalDay.today.advanced(by: -3)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: .today)
        )
        
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        
        XCTAssertEqual(state.isolation, Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: .rapidResult, isSelfDiagnosed: false, isPendingConfirmation: true), contactCaseInfo: .init(optOutOfIsolationDay: nil))))
    }
    
    // MARK: Exposure notification processing behaviour
    
    func testExposureNotificationProcessingBehaviourIsNoneWhenIsolatingFromContactCase() {
        let state: IsolationLogicalState = isolating(for: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil)))
        
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
        XCTAssertTrue(behaviour.shouldNotifyForExposure(on: .today))
    }
    
    func testExposureNotificationProcessingBehaviourSaysShouldHandleExposuresOnOrAfterDateWeOptedIntoDCT() {
        let behaviour = ExposureNotificationProcessingBehaviour.onlyProcessExposuresOnOrAfter(.today)
        XCTAssertFalse(behaviour.shouldNotifyForExposure(on: GregorianDay.today.advanced(by: -1)))
        XCTAssertTrue(behaviour.shouldNotifyForExposure(on: .today))
        XCTAssertTrue(behaviour.shouldNotifyForExposure(on: GregorianDay.today.advanced(by: 1)))
    }
    
    func testExposureNotificationProcessingBehaviourSaysShouldNotHandleExposuresIfNotInterested() {
        let behaviour = ExposureNotificationProcessingBehaviour.doNotProcessExposures
        XCTAssertFalse(behaviour.shouldNotifyForExposure(on: .today))
    }
    
    // MARK: Early release from isolation when person opts into daily contact testing
    
    // TODO: Write some more tests to cover successive isolations.
    
    func testReleasedFromIsolationWhenPersonOptsIntoDCT() {
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: GregorianDay.today.advanced(by: -2), isolationFromStartOfDay: $state.today.gregorianDay, optOutOfIsolationDay: .today)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: .today, timeZone: $state.today.timeZone), reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: .today))))
    }
}

private extension IsolationLogicalStateTests {
    func isolating(for reason: Isolation.Reason) -> IsolationLogicalState {
        .isolating(
            Isolation(fromDay: LocalDay.today.advanced(by: -2), untilStartOfDay: .today, reason: reason),
            endAcknowledged: false,
            startAcknowledged: true
        )
    }
}

private extension IndexCaseInfo {
    
    init(selfDiagnosisDay: GregorianDay, onsetDay: GregorianDay?, testResult: TestResult?) {
        self.init(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: onsetDay,
            testInfo: testResult.map { TestInfo(result: $0, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: .today) }
        )
    }
    
}
