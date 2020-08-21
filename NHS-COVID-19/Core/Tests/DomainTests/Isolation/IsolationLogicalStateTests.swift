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
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false)))
    }
    
    func testIndexCaseNegativeTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false)))
    }
    
    func testIndexCasePositiveTestResultNoOnsetDay() {
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 9)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true)))
    }
    
    func testIndexCaseNegativeTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: $state.today.gregorianDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false)))
    }
    
    func testIndexCasePositiveTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true)))
    }
    
    func testIndexCaseNoTestResultWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 7)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: false)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationNoOnsetDay() {
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisUnknownOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true)))
    }
    
    func testIsolationPeriodNotGreaterThanConfigurationMaxIsolationWithOnsetDay() {
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -1)
        $state.isolationConfiguration.indexCaseSinceSelfDiagnosisOnset = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .indexCase(hasPositiveTestResult: true)))
    }
    
    func testContactCase() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .contactCase))
    }
    
    func testContactCaseIsolationPeriodNotGreaterThanConfigurationMaxIsolation() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationConfiguration.contactCase = 50
        $state.isolationConfiguration.maxIsolation = 5
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        let endDay = $state.selfDiagnosisDay.advanced(by: 5)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .contactCase))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDay() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: nil)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases))
    }
    
    func testContactCaseWithIndexCaseNoOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: nil, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayPositiveTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases))
    }
    
    func testContactCaseWithIndexCaseWithOnsetDayNegativeTestResult() {
        let exposureDay = $state.selfDiagnosisDay.advanced(by: -2)
        let onsetDay = $state.selfDiagnosisDay.advanced(by: -3)
        $state.isolationInfo.contactCaseInfo = ContactCaseInfo(exposureDay: exposureDay, isolationFromStartOfDay: $state.today.gregorianDay)
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .negative)
        let endDay = $state.selfDiagnosisDay.advanced(by: 12)
        XCTAssertEqual(state.isolation, Isolation(fromDay: .today, untilStartOfDay: LocalDay(gregorianDay: endDay, timeZone: $state.today.timeZone), reason: .bothCases))
    }
    
    // MARK: Isolation has ended
    
    func testEndOfIsolationBeforeTodayDoesNotTriggerIsolation() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 10)
        
        let endDay = $state.today.advanced(by: -2)
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: true))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolation() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        
        XCTAssertEqual(state, .isolationFinishedButNotAcknowledged(Isolation(fromDay: .today, untilStartOfDay: $state.today, reason: .indexCase(hasPositiveTestResult: true))))
    }
    
    func testEndOfIsolationBeforeTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 10)
        
        let endDay = $state.today.advanced(by: -2)
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: true))))
    }
    
    func testEndOfIsolationAtStartOfTodayDoesNotTriggerIsolationWhenAcknowledged() {
        let onsetDay = $state.selfDiagnosisDay
        $state.isolationInfo.hasAcknowledgedEndOfIsolation = true
        $state.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $state.selfDiagnosisDay, onsetDay: onsetDay, testResult: .positive)
        
        $state.today.gregorianDay = $state.selfDiagnosisDay.advanced(by: 8)
        
        let endDay = $state.today
        XCTAssertEqual(state, .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation(fromDay: .today, untilStartOfDay: endDay, reason: .indexCase(hasPositiveTestResult: true))))
    }
    
}

private extension IndexCaseInfo {
    
    init(selfDiagnosisDay: GregorianDay, onsetDay: GregorianDay?, testResult: TestResult?) {
        self.init(
            selfDiagnosisDay: selfDiagnosisDay,
            onsetDay: onsetDay,
            testInfo: testResult.map { TestInfo(result: $0, receivedOnDay: .today) }
        )
    }
    
}
