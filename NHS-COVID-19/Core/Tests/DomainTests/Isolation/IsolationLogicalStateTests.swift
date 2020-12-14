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
            housekeepingDeletionPeriod: 14
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

// TODO: Unify with `IsolationLogicalStateTests`
class _IsolationLogicalStateTests: XCTestCase {
    
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
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)))
    }
    
    func testIndexCaseNegativeTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)))
    }
    
    func testIndexCasePositiveTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 9)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true)))
    }
    
    func testIndexCaseNegativeTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)))
    }
    
    func testIndexCasePositiveTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true)))
    }
    
    func testIndexCaseNoTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationNoOnsetDay() {
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisUnknownOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true)))
    }
    
    func testContactCase() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .contactCase(.exposureDetection)))
    }
    
    func testContactCaseIsolationPeriodNotGreaterThanConfigurationMaxIsolation() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationConfiguration.contactCase = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .contactCase(.exposureDetection)))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases(hasPositiveTestResult: false, isSelfDiagnosed: true)))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases(hasPositiveTestResult: false, isSelfDiagnosed: true)))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases(hasPositiveTestResult: true, isSelfDiagnosed: true)))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .contactCase(.exposureDetection)))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases(hasPositiveTestResult: true, isSelfDiagnosed: true)))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .contactCase(.exposureDetection)))
    }
    
    // MARK: Financial Support
    
    func testCannotApplyFinancialSupportWhenNotIsolating() {
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testCannotApplyFinancialSupportWhenIsolationExceeded() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -14)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testCannotApplyFinancialSupportWhenItsAnIndexCase() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testisInCorrectIsolationStateToApplyForFinancialSupportWhenItsAContactCase() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        XCTAssertTrue(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testisInCorrectIsolationStateToApplyForFinancialSupportWhenItsBothCases() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        XCTAssertTrue(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    func testisInCorrectIsolationStateToApplyForFinancialSupportWhenItsBothCasesAndPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay, trigger: .exposureDetection)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        XCTAssertFalse(state.isInCorrectIsolationStateToApplyForFinancialSupport)
    }
    
    // MARK: Isolation has ended
    
    func testEndOfIsolationBeforeTodayDoesNotTriggerIsolation() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 10)
        
        let endDay = $state.today.advanced(by: -2)
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolation() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: $state.today, reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true))))
    }
    
    func testEndOfIsolationBeforeTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 10)
        
        let endDay = $state.today.advanced(by: -2)
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        
        let endDay = $state.today
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true))))
    }
    
    func testManualTestEntryTriggersIsolation() {
        let npexDay = LocalDay.today.advanced(by: -2)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, receivedOnDay: .today)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        XCTAssertEqual(state.isolation, Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: false)))
    }
    
    func testManualTestEntryWithVoidResultDoesNotTriggerIsolation() {
        let npexDay = LocalDay.today.advanced(by: -2)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .void, receivedOnDay: .today)
        )
        
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))
    }
    
    func testManualTestEntryWithOldTestDoesNotTriggerIsolation() {
        let npexDay = LocalDay.today.advanced(by: -12)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, receivedOnDay: .today)
        )
        
        let endDay = npexDay.advanced(by: $state.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).gregorianDay
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: npexDay, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: false))))
    }
    
    // MARK: Interested in exposure notifications
    func testInterestedInExposureNotificationsTrueWhenNotIsolating() {
        let state: IsolationLogicalState = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        XCTAssertTrue(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromContactCase() {
        let state: IsolationLogicalState = isolating(for: .contactCase(.exposureDetection))
            
        XCTAssertFalse(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromBothCases() {
        let state: IsolationLogicalState = isolating(for: .bothCases(hasPositiveTestResult: true, isSelfDiagnosed: true))
        
        XCTAssertFalse(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsFalseWhenIsolatingFromIndexCaseWithPositiveTest() {
        let state: IsolationLogicalState = isolating(for: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true))
        
        XCTAssertFalse(state.interestedInExposureNotifications)
    }
    
    func testInterestedInExposureNotificationsTrueWhenIsolatingFromIndexCaseWithNoPositiveTest() {
        let state: IsolationLogicalState = isolating(for: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true))
        
        XCTAssertTrue(state.interestedInExposureNotifications)
    }
}

private extension _IsolationLogicalStateTests {
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
            testInfo: testResult.map { TestInfo(result: $0, receivedOnDay: .today) }
        )
    }
    
}
