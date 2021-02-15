//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class TestResultIsolationOperationTests: XCTestCase {
    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var today = LocalDay.today
            lazy var selfDiagnosisDay = today.gregorianDay
            var encryptedStore = MockEncryptedStore()
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
        
        let store: IsolationInfo
        let isolationState: IsolationLogicalState
        
        init(configuration: Configuration) {
            store = configuration.isolationInfo
            isolationState = IsolationLogicalState(
                today: configuration.today,
                info: configuration.isolationInfo,
                configuration: configuration.isolationConfiguration
            )
        }
    }
    
    @Propped
    var instance: Instance
    
    var store: IsolationInfo {
        instance.store
    }
    
    var isolationState: IsolationLogicalState {
        instance.isolationState
    }
    
    func testPositiveTestShouldUpdateWhileBeingInSymptomaticIsolation() throws {
        $instance.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $instance.selfDiagnosisDay, onsetDay: nil, testResult: nil)
        
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        // Given
        let isolationInfo = IsolationInfo(indexCaseInfo: IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: nil,
            testInfo: nil
        ), contactCaseInfo: nil)
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: testReceivedDay.startDate(in: .utc),
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .update)
    }
    
    func testPositiveRequiresConfirmatoryTestShouldNotBeSavedWhileBeingInSymptomaticIsolation() throws {
        $instance.isolationInfo.indexCaseInfo = IndexCaseInfo(selfDiagnosisDay: $instance.selfDiagnosisDay, onsetDay: nil, testResult: nil)
        
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        // Given
        let isolationInfo = IsolationInfo(indexCaseInfo: IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: nil,
            testInfo: nil
        ), contactCaseInfo: nil)
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: testReceivedDay.advanced(by: -1).startDate(in: .utc),
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: true
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .nothing)
    }
    
    func testInIsolationEnteringNewPositiveRequiresConfirmatoryTestShouldNotOverrideExistingOne() {
        let firstRapidTestReceivedDay = LocalDay.today.advanced(by: -3).gregorianDay
        let firstRapidTestNpexDay = firstRapidTestReceivedDay.advanced(by: -1)
        
        let secondRapidTestReceivedDay = LocalDay.today
        
        let indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: firstRapidTestNpexDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .positive,
                testKitType: .rapidResult,
                requiresConfirmatoryTest: true,
                receivedOnDay: firstRapidTestReceivedDay
            )
        )
        
        // GIVEN
        $instance.isolationInfo.indexCaseInfo = indexCaseInfo
        let isolationInfo = IsolationInfo(indexCaseInfo: indexCaseInfo)
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: secondRapidTestReceivedDay.advanced(by: -1).startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: true
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .nothing)
    }
    
    func testInIsolationEnteringNewPositiveTestShouldOverrideExistingOne() {
        let firstRapidTestReceivedDay = GregorianDay(year: 2020, month: 7, day: 16)
        let firstRapidTestNpexDay = firstRapidTestReceivedDay.advanced(by: -1)
        
        let secondRapidTestReceivedDay = GregorianDay(year: 2020, month: 7, day: 20)
        
        let indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: firstRapidTestNpexDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .positive,
                testKitType: .rapidResult,
                requiresConfirmatoryTest: true,
                receivedOnDay: firstRapidTestReceivedDay
            )
        )
        
        // GIVEN
        $instance.isolationInfo.indexCaseInfo = indexCaseInfo
        let isolationInfo = IsolationInfo(indexCaseInfo: indexCaseInfo)
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: secondRapidTestReceivedDay.advanced(by: -1).startDate(in: .utc),
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .confirm)
    }
    
    func testInIsolationEnteringNewPositiveTestShouldNotOverrideExistingOne() {
        let firstRapidTestReceivedDay = LocalDay.today.gregorianDay.advanced(by: -1)
        let firstRapidTestNpexDay = firstRapidTestReceivedDay.advanced(by: -1)
        
        let secondRapidTestReceivedDay = LocalDay.today.gregorianDay
        
        let indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: firstRapidTestNpexDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .positive,
                testKitType: .rapidResult,
                requiresConfirmatoryTest: false,
                receivedOnDay: firstRapidTestReceivedDay
            )
        )
        
        // GIVEN
        $instance.isolationInfo.indexCaseInfo = indexCaseInfo
        let isolationInfo = IsolationInfo(indexCaseInfo: indexCaseInfo)
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: secondRapidTestReceivedDay.advanced(by: -1).startDate(in: .utc),
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: true
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .nothing)
    }
    
    func testShouldStartIsolationBecauseOfPositiveTestResultRequiresConfirmatoryTestAfterBeingRecentlyReleasedFromIsolation() {
        let npexDay = LocalDay.today.advanced(by: -15)
        let indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay.gregorianDay),
            onsetDay: nil,
            testInfo: .init(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: .today)
        )
        let isolationInfo = IsolationInfo(indexCaseInfo: indexCaseInfo)
        
        let endDay = npexDay.advanced(by: $instance.isolationConfiguration.indexCaseSinceNPEXDayNoSelfDiagnosis.days).startOfDay
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: endDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: true
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .overwrite)
    }
    
    func testShouldStartIsolationBecauseOfPositiveTestResultRequiresConfirmatoryTestAfterBeingRecentlyReleasedFromContactIsolation() {
        let exposureDay = LocalDay.today.advanced(by: -15).gregorianDay
        let isolationFromStartOfDay = LocalDay.today.advanced(by: -15).gregorianDay
        let contactCaseInfo = ContactCaseInfo(
            exposureDay: exposureDay,
            isolationFromStartOfDay: isolationFromStartOfDay
        )
        let isolationInfo = IsolationInfo(indexCaseInfo: nil, contactCaseInfo: contactCaseInfo)
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: true
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .overwrite)
    }
    
    func testNotOverwritePositiveTestResult() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        
        let isolationInfo = IsolationInfo(indexCaseInfo: IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: GregorianDay(year: 2020, month: 7, day: 16)),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .positive,
                testKitType: .labResult,
                requiresConfirmatoryTest: false,
                receivedOnDay: testDay
            )
        ), contactCaseInfo: nil)
        
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .negative,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .nothing)
    }
    
    func testDoNothingWhenVoidResult() throws {
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: IsolationInfo.empty,
            result: VirologyStateTestResult(
                testResult: .void,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .nothing)
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsPositiveAndPreviousTestResultIsNegative() throws {
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(indexCaseInfo: IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(testReceivedDay.advanced(by: -2)),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .negative, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay.advanced(by: -1))
        ), contactCaseInfo: nil)
        
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .overwrite)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsPositiveAndPreviousTestResultIsPositive() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let selfDiagnosisDay = testDay.advanced(by: -6)
        
        // Given
        let isolationInfo = IsolationInfo(indexCaseInfo: IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: selfDiagnosisDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .positive,
                testKitType: .labResult,
                requiresConfirmatoryTest: false,
                receivedOnDay: testDay.advanced(by: -4)
            )
        ), contactCaseInfo: nil)
        
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .nothing)
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsPositiveAndPreviousTestResultIsVoid() throws {
        let testDay = LocalDay.today.gregorianDay
        let selfDiagnosisDay = testDay.advanced(by: -6)
        
        let indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: selfDiagnosisDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .void,
                testKitType: .labResult,
                requiresConfirmatoryTest: false,
                receivedOnDay: testDay.advanced(by: -4)
            )
        )
        
        // GIVEN
        $instance.isolationInfo.indexCaseInfo = indexCaseInfo
        let isolationInfo = IsolationInfo(indexCaseInfo: indexCaseInfo)
        
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .update)
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsPositiveAndPreviousTestResultIsNil() throws {
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: IsolationInfo.empty,
            result: VirologyStateTestResult(
                testResult: .positive,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .overwrite)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsNegativeAndPreviousTestResultIsNegative() throws {
        let testDay = LocalDay.today.gregorianDay.advanced(by: -1)
        
        // Given
        let indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: testDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .negative,
                testKitType: .labResult,
                requiresConfirmatoryTest: false,
                receivedOnDay: testDay.advanced(by: -4)
            )
        )
        
        // GIVEN
        $instance.isolationInfo.indexCaseInfo = indexCaseInfo
        let isolationInfo = IsolationInfo(indexCaseInfo: indexCaseInfo)
        
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .negative,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .nothing)
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsNegativeAndPreviousTestResultIsVoid() {
        let testDay = LocalDay.today.gregorianDay
        let selfDiagnosisDay = testDay.advanced(by: -6)
        
        // Given
        let isolationInfo = IsolationInfo(indexCaseInfo: IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: selfDiagnosisDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(
                result: .void,
                testKitType: .labResult,
                requiresConfirmatoryTest: false,
                receivedOnDay: testDay.advanced(by: -4)
            )
        ), contactCaseInfo: nil)
        
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: isolationInfo,
            result: VirologyStateTestResult(
                testResult: .negative,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .update)
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsNegativeAndPreviousTestResultIsNil() throws {
        // When
        let operation = TestResultIsolationOperation(
            currentIsolationState: isolationState,
            storedIsolationInfo: IsolationInfo.empty,
            result: VirologyStateTestResult(
                testResult: .negative,
                testKitType: .labResult,
                endDate: LocalDay.today.startOfDay,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: false
            )
        )
        
        // THEN
        XCTAssertEqual(operation.storeOperation(), .overwrite)
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
