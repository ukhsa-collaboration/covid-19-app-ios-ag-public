//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class IsolationContextTests: XCTestCase {
    private var isolationContext: IsolationContext!
    private var currentDate: Date!
    private var client: MockHTTPClient!
    private var removedNotificaton = false
    
    override func setUp() {
        currentDate = Date()
        client = MockHTTPClient()
        
        isolationContext = IsolationContext(
            isolationConfiguration: CachedResponse(
                httpClient: client,
                endpoint: IsolationConfigurationEndpoint(),
                storage: FileStorage(forCachesOf: .random()),
                name: "isolation_configuration",
                initialValue: EnglandAndWalesIsolationConfigurations(
                    england: IsolationConfiguration(
                        maxIsolation: 21,
                        contactCase: 14,
                        indexCaseSinceSelfDiagnosisOnset: 8,
                        indexCaseSinceSelfDiagnosisUnknownOnset: 9,
                        housekeepingDeletionPeriod: 14,
                        indexCaseSinceNPEXDayNoSelfDiagnosis: 11,
                        testResultPollingTokenRetentionPeriod: 28
                    ),
                    wales: IsolationConfiguration(
                        maxIsolation: 21,
                        contactCase: 14,
                        indexCaseSinceSelfDiagnosisOnset: 8,
                        indexCaseSinceSelfDiagnosisUnknownOnset: 9,
                        housekeepingDeletionPeriod: 14,
                        indexCaseSinceNPEXDayNoSelfDiagnosis: 11,
                        testResultPollingTokenRetentionPeriod: 28
                    )
                )
            ),
            encryptedStore: MockEncryptedStore(),
            notificationCenter: NotificationCenter(),
            currentDateProvider: MockDateProvider { self.currentDate },
            removeExposureDetectionNotifications: { self.removedNotificaton = true },
            country: Just(Country.england).domainProperty()
        )
    }
    
    func testCanBookALabTestIfInDateRangeAndNotIsolating() throws {
        let isoInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            hasAcknowledgedStartOfContactIsolation: true,
            indexCaseInfo: nil,
            contactCaseInfo: ContactCaseInfo(exposureDay: .today, isolationFromStartOfDay: .today, optOutOfIsolationDay: .today)
        )
        
        isolationContext.isolationStateManager.state = IsolationLogicalState(stateInfo: IsolationStateInfo(isolationInfo: isoInfo, configuration: .defaultEngland), day: .today)
        
        let canBookALabTest = try isolationContext.canBookALabTest().await().get()
        XCTAssertTrue(canBookALabTest)
    }
    
    func testCanBookALabTestIfNotInDateRangeAndNotIsolating() throws {
        let config = isolationContext.isolationConfiguration.value
        let exposureDay = GregorianDay.today.advanced(by: -config.england.contactCase.days)
        
        let isoInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            hasAcknowledgedStartOfContactIsolation: true,
            indexCaseInfo: nil,
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: exposureDay,
                optOutOfIsolationDay: exposureDay
            )
        )
        
        isolationContext.isolationStateManager.state = IsolationLogicalState(stateInfo: IsolationStateInfo(isolationInfo: isoInfo, configuration: config.england), day: .today)
        
        let canBookALabTest = try isolationContext.canBookALabTest().await().get()
        XCTAssertFalse(canBookALabTest)
    }
    
    func testCanBookALabTestIfIsolationFinishedAndNotAcknowledged() throws {
        let config = isolationContext.isolationConfiguration.value
        let exposureDay = GregorianDay.today.advanced(by: -config.england.contactCase.days)
        
        let isoInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: true,
            indexCaseInfo: nil,
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: exposureDay,
                optOutOfIsolationDay: exposureDay
            )
        )
        
        isolationContext.isolationStateManager.state = IsolationLogicalState(stateInfo: IsolationStateInfo(isolationInfo: isoInfo, configuration: config.england), day: .today)
        
        let canBookALabTest = try isolationContext.canBookALabTest().await().get()
        XCTAssertFalse(canBookALabTest)
    }
    
    func testCanBookALabTestIfInIsolation() throws {
        let config = isolationContext.isolationConfiguration.value
        let exposureDay = GregorianDay.today.advanced(by: -1)
        
        let isoInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: true,
            indexCaseInfo: nil,
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: exposureDay,
                optOutOfIsolationDay: GregorianDay.today.advanced(by: 1)
            )
        )
        
        isolationContext.isolationStateManager.state = IsolationLogicalState(stateInfo: IsolationStateInfo(isolationInfo: isoInfo, configuration: config.england), day: .today)
        
        let canBookALabTest = try isolationContext.canBookALabTest().await().get()
        XCTAssertTrue(canBookALabTest)
    }
    
    func testMakeIsolationAcknowledgementStatePublishesState() throws {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(exposureDay: .today)))
        isolationContext.isolationStateManager.state = .isolationFinishedButNotAcknowledged(isolation)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        guard case .neededForEnd(isolation, _) = ackState else {
            throw TestError("Unexpected state \(ackState)")
        }
    }
    
    func testMakeBackgroundJobs() throws {
        let backgroundJobs = isolationContext.makeBackgroundJobs()
        
        XCTAssertEqual(backgroundJobs.count, 3)
        
        client.response = Result.success(.ok(with: .json("""
        {
          "durationDays": {
            "indexCaseSinceSelfDiagnosisOnset": 1,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 2,
            "contactCase": 3,
            "maxIsolation": 4
          }
        }
        
        """)))
        
        try backgroundJobs.forEach { job in
            try job.work().await().get()
        }
        
        let request = try XCTUnwrap(client.lastRequest)
        let expectedRequest = try IsolationConfigurationEndpoint().request(for: ())
        XCTAssertEqual(request, expectedRequest)
    }
    
    func testRemoveExposureDetectionNotificationOnContactCaseAcknowledgement() throws {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: .init(indexCaseInfo: nil, contactCaseInfo: .init(exposureDay: .today)))
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startOfContactIsolationAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStartContactIsolation(isolation, acknowledge: let ack) = ackState {
            ack(false)
            XCTAssertTrue(removedNotificaton)
        }
    }
    
    // The notification should only be removed if a user acknowledges his isolation due to a risky contact
    // This is currently only possible as contact case only.
    // Revisit this test after changing the logic when to show the "isolate due to risky contact" screen
    func testDoNotRemoveExposureDetectionNotificationOnBothCases() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .init(
                indexCaseInfo: .init(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false),
                contactCaseInfo: nil
            )
        )
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startOfContactIsolationAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStartContactIsolation(isolation, acknowledge: let ack) = ackState {
            ack(false)
            XCTAssertFalse(removedNotificaton)
        }
    }
    
    // The notification should only be removed if a user acknowledges his isolation due to a risky contact
    // This is currently only possible as contact case only.
    // Revisit this test after changing the logic when to show the "isolate due to risky contact" screen
    func testDoNotRemoveExposureDetectionNotificationOnIndexCase() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .init(
                indexCaseInfo: .init(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false),
                contactCaseInfo: nil
            )
        )
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startOfContactIsolationAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStartContactIsolation(isolation, acknowledge: let ack) = ackState {
            ack(false)
            XCTAssertFalse(removedNotificaton)
        }
    }
    
    // MARK: Tests for makeResultAcknowledgementState
    
    private func makeResultAcknowledgementState(result: VirologyStateTestResult) -> AnyPublisher<TestResultAcknowledgementState, Never> {
        isolationContext.makeResultAcknowledgementState(
            result: result,
            completionHandler: { _ in }
        )
    }
    
    func testPositiveNotIsolatingStartsIsolation() throws {
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random()),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultStartToIsolate(let acknowledge, _) = state {
            acknowledge()
            XCTAssertTrue(isolationContext.isolationStateManager.state.isIsolating)
        } else {
            XCTFail("Unexpected state \(state)")
        }
        
    }
    
    func testPositiveNotAcknowledgedEndOfIsolationWillAcknowledgeEndOfIsolation() throws {
        let date = GregorianDay.today
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: date.advanced(by: -9), onsetDay: nil),
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random()),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating(let acknowledge) = state {
            acknowledge()
            XCTAssertFalse(isolationContext.isolationStateManager.state.isIsolating)
            XCTAssertTrue(isolationContext.isolationStateStore
                .isolationInfo.hasAcknowledgedEndOfIsolation)
        } else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testConfirmedPositiveAlreadyOutOfIsolationNoNewIsolation() throws {
        let date = GregorianDay.today
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: date.advanced(by: -15), onsetDay: nil),
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating(let acknowledge) = state {
            acknowledge()
            XCTAssertFalse(isolationContext.isolationStateManager.state.isIsolating)
        } else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testUnConfirmedPositiveAlreadyOutOfIsolationNoNewIsolation() throws {
        let date = GregorianDay.today
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: date.advanced(by: -15), onsetDay: nil),
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .rapidResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random()),
            requiresConfirmatoryTest: true,
            shouldOfferFollowUpTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultStartToIsolate(let acknowledge, _) = state {
            acknowledge()
            XCTAssertTrue(isolationContext.isolationStateManager.state.isIsolating)
        } else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testNegativeIsolatingAsContactKeepsIsolation() throws {
        isolationContext.isolationStateStore.set(
            ContactCaseInfo(exposureDay: .today, isolationFromStartOfDay: .today)
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForNegativeResultContinueToIsolate(let ack, _) = state {
            ack()
            XCTAssertTrue(isolationContext.isolationStateManager.state.isIsolating)
        } else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testNegativeNotAcknowledgedEndOfIsolationWillAcknowledgeEndOfIsolation() throws {
        let date = GregorianDay.today
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: date.advanced(by: -9), onsetDay: nil),
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForNegativeResultNotIsolating(let ack) = state {
            ack()
            XCTAssertFalse(isolationContext.isolationStateManager.state.isIsolating)
            XCTAssertTrue(isolationContext.isolationStateStore.isolationInfo.hasAcknowledgedEndOfIsolation)
        } else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testOptOutOfIsolationWhenContactCaseOnly() throws {
        let exposureDay = GregorianDay.today.advanced(by: -1)
        
        // store a contact case
        isolationContext.isolationStateStore.set(
            ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        // confirm the state of the current isolation
        XCTAssertTrue(isolationContext.isolationStateManager.isolationLogicalState.currentValue.activeIsolation!.isContactCaseOnly)
        
        isolationContext.optOutContactIsolationOnExposurerDay()
        
        let contactCaseInfo = isolationContext.isolationStateStore.isolationInfo.contactCaseInfo
        XCTAssertEqual(contactCaseInfo?.optOutOfIsolationDay, exposureDay)
        XCTAssertTrue(isolationContext.isolationStateStore.isolationInfo.hasAcknowledgedEndOfIsolation)
    }
    
    func testOptOutOfIsolationWhenIndexAndContactCase() throws {
        let exposureDay = GregorianDay.today.advanced(by: -1)
        
        // store a contact case
        isolationContext.isolationStateStore.set(
            ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: .today, onsetDay: .today),
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        // confirm the state of the current isolation
        XCTAssertTrue(isolationContext.isolationStateManager.isolationLogicalState.currentValue.activeIsolation!.isContactCase)
        XCTAssertTrue(isolationContext.isolationStateManager.isolationLogicalState.currentValue.activeIsolation!.isIndexCase)
        
        isolationContext.optOutContactIsolationOnExposurerDay()
        
        // confirm that the optOutOfIsolationDay field is nil
        let contactCaseInfo = isolationContext.isolationStateStore.isolationInfo.contactCaseInfo
        XCTAssertEqual(contactCaseInfo?.optOutOfIsolationDay, exposureDay)
        XCTAssertFalse(isolationContext.isolationStateStore.isolationInfo.hasAcknowledgedEndOfIsolation)
    }
    
    func testHandleSymptomsWithoutTest() {
        let onsetDay = GregorianDay.today
        let fromDay = LocalDay(gregorianDay: onsetDay, timeZone: .current)
        let untilStartOfDay = fromDay.advanced(by: isolationContext.isolationConfiguration.value.england.indexCaseSinceSelfDiagnosisOnset.days)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = isolationContext.isolationConfiguration.value.england.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        let state = isolationContext.handleSymptomsIsolationState(onsetDay: onsetDay, symptomaticSelfIsolationEnabled: false)
        
        let expectedIsolationState = IsolationState.isolate(
            Isolation(
                fromDay: fromDay,
                untilStartOfDay: untilStartOfDay,
                reason: .init(
                    indexCaseInfo: .init(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration),
                    contactCaseInfo: nil
                )
            )
        )
        XCTAssertEqual(state.0, expectedIsolationState)
        XCTAssertEqual(state.1, .hasNoTest)
    }
    
    func testHandleSymptomsAfterTest() {
        let onsetDay = GregorianDay.today
        let receivedOnDay = GregorianDay.today
        let testEndDay = GregorianDay.today.advanced(by: -2)
        let fromDay = LocalDay(gregorianDay: onsetDay, timeZone: .current)
        let untilStartOfDay = fromDay.advanced(by: isolationContext.isolationConfiguration.value.england.indexCaseSinceSelfDiagnosisOnset.days)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = isolationContext.isolationConfiguration.value.england.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(
                    result: .positive,
                    requiresConfirmatoryTest: false,
                    shouldOfferFollowUpTest: false,
                    receivedOnDay: receivedOnDay,
                    testEndDay: testEndDay
                )
            )
        )
        
        let state = isolationContext.handleSymptomsIsolationState(onsetDay: onsetDay, symptomaticSelfIsolationEnabled: false)
        let expectedIsolationState = IsolationState.isolate(
            Isolation(
                fromDay: fromDay,
                untilStartOfDay: untilStartOfDay,
                reason: .init(
                    indexCaseInfo: .init(hasPositiveTestResult: true, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration),
                    contactCaseInfo: nil
                )
            )
        )
        XCTAssertEqual(state.0, expectedIsolationState)
        XCTAssertEqual(state.1, .hasTest(shouldChangeAdviceDueToSymptoms: true))
    }
    
    func testHandleSymptomsAfterExpiredTest() {
        let onsetDay = GregorianDay.today
        let receivedOnDay = GregorianDay.today
        let testEndDay = GregorianDay.today.advanced(by: -11)
        let fromDay = LocalDay(gregorianDay: onsetDay, timeZone: .current)
        let untilStartOfDay = fromDay.advanced(by: isolationContext.isolationConfiguration.value.england.indexCaseSinceSelfDiagnosisOnset.days)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = isolationContext.isolationConfiguration.value.england.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(
                    result: .positive,
                    requiresConfirmatoryTest: false,
                    shouldOfferFollowUpTest: false,
                    receivedOnDay: receivedOnDay,
                    testEndDay: testEndDay
                )
            )
        )
        
        let state = isolationContext.handleSymptomsIsolationState(onsetDay: onsetDay, symptomaticSelfIsolationEnabled: false)
        let expectedIsolationState = IsolationState.isolate(
            Isolation(
                fromDay: fromDay,
                untilStartOfDay: untilStartOfDay,
                reason: .init(
                    indexCaseInfo: .init(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration),
                    contactCaseInfo: nil
                )
            )
        )
        XCTAssertEqual(state.0, expectedIsolationState)
        XCTAssertEqual(state.1, .hasNoTest)
    }
    
    func testHandleSymptomsAfterExpiredTestButActiveContactCase() {
        let onsetDay = GregorianDay.today
        let receivedOnDay = GregorianDay.today
        let testEndDay = GregorianDay.today.advanced(by: -11)
        let fromDay = LocalDay(gregorianDay: onsetDay, timeZone: .current)
        let untilStartOfDay = fromDay.advanced(by: isolationContext.isolationConfiguration.value.england.contactCase.days)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = isolationContext.isolationConfiguration.value.england.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(
                    result: .positive,
                    requiresConfirmatoryTest: false,
                    shouldOfferFollowUpTest: false,
                    receivedOnDay: receivedOnDay,
                    testEndDay: testEndDay
                )
            )
        )
        
        isolationContext.isolationStateStore.set(
            ContactCaseInfo(
                exposureDay: .today,
                isolationFromStartOfDay: .today
            )
        )
        
        let state = isolationContext.handleSymptomsIsolationState(onsetDay: onsetDay, symptomaticSelfIsolationEnabled: false)
        let expectedIsolationState = IsolationState.isolate(
            Isolation(
                fromDay: fromDay,
                untilStartOfDay: untilStartOfDay,
                reason: .init(
                    indexCaseInfo: .init(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration),
                    contactCaseInfo: .init(exposureDay: .today)
                )
            )
        )
        XCTAssertEqual(state.0, expectedIsolationState)
        XCTAssertEqual(state.1, .hasNoTest)
    }
    
    func testHandleSymptomsBeforeTest() {
        let onsetDay = GregorianDay.today.advanced(by: -2)
        let receivedOnDay = GregorianDay.today
        let testEndDay = GregorianDay.today
        let fromDay = LocalDay(gregorianDay: testEndDay, timeZone: .current)
        let untilStartOfDay = fromDay.advanced(by: isolationContext.isolationConfiguration.value.england.indexCaseSinceNPEXDayNoSelfDiagnosis.days)
        let numberOfIsolationDaysForIndexCaseFromConfiguration = isolationContext.isolationConfiguration.value.england.indexCaseSinceNPEXDayNoSelfDiagnosis.days
        
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(
                    result: .positive,
                    requiresConfirmatoryTest: false,
                    shouldOfferFollowUpTest: false,
                    receivedOnDay: receivedOnDay,
                    testEndDay: testEndDay
                )
            )
        )
        
        let state = isolationContext.handleSymptomsIsolationState(onsetDay: onsetDay, symptomaticSelfIsolationEnabled: false)
        let expectedIsolationState = IsolationState.isolate(
            Isolation(
                fromDay: fromDay,
                untilStartOfDay: untilStartOfDay,
                reason: .init(
                    indexCaseInfo: .init(hasPositiveTestResult: true, testKitType: nil, isSelfDiagnosed: false, isPendingConfirmation: false, numberOfIsolationDaysForIndexCaseFromConfiguration: numberOfIsolationDaysForIndexCaseFromConfiguration),
                    contactCaseInfo: nil
                )
            )
        )
        XCTAssertEqual(state.0, expectedIsolationState)
        XCTAssertEqual(state.1, .hasTest(shouldChangeAdviceDueToSymptoms: false))
    }
    
}
