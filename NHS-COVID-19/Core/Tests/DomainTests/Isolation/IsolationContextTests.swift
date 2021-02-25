//
// Copyright © 2021 DHSC. All rights reserved.
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
                storage: FileStorage(forNewCachesOf: .random()),
                name: "isolation_configuration",
                initialValue: IsolationConfiguration(
                    maxIsolation: 21,
                    contactCase: 14,
                    indexCaseSinceSelfDiagnosisOnset: 8,
                    indexCaseSinceSelfDiagnosisUnknownOnset: 9,
                    housekeepingDeletionPeriod: 14,
                    indexCaseSinceNPEXDayNoSelfDiagnosis: IsolationConfiguration.default.indexCaseSinceNPEXDayNoSelfDiagnosis
                )
            ),
            encryptedStore: MockEncryptedStore(),
            notificationCenter: NotificationCenter(),
            currentDateProvider: MockDateProvider { self.currentDate },
            removeExposureDetectionNotifications: { self.removedNotificaton = true }
        )
    }
    
    func testMakeIsolationAcknowledgementStatePublishesState() throws {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: .init(optOutOfIsolationDay: nil)))
        isolationContext.isolationStateManager.state = .isolationFinishedButNotAcknowledged(isolation)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        guard case .neededForEnd(isolation, _) = ackState else {
            throw TestError("Unexpected state \(ackState)")
        }
    }
    
    func testMakeBackgroundJobs() throws {
        let backgroundJobs = isolationContext.makeBackgroundJobs(
            metricsFrequency: 1.0,
            housekeepingFrequency: 1.0
        )
        
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
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: .init(indexCaseInfo: nil, contactCaseInfo: .init(optOutOfIsolationDay: nil)))
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStart(isolation, acknowledge: let ack) = ackState {
            ack()
            
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
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStart(isolation, acknowledge: let ack) = ackState {
            ack()
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
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStart(isolation, acknowledge: let ack) = ackState {
            ack()
            XCTAssertFalse(removedNotificaton)
        }
    }
    
    // MARK: Tests for makeResultAcknowledgementState
    
    private func makeResultAcknowledgementState(result: VirologyStateTestResult) -> AnyPublisher<TestResultAcknowledgementState, Never> {
        isolationContext.makeResultAcknowledgementState(
            result: result,
            positiveAcknowledgement: { _, _, _, completionHandler in TestResultAcknowledgementState.PositiveResultAcknowledgement(
                acknowledge: {
                    completionHandler(.sent)
                    return Empty().eraseToAnyPublisher()
                },
                acknowledgeWithoutSending: {
                    completionHandler(.notSent)
                }
            )
            },
            completionHandler: { _ in }
        )
    }
    
    func testPositiveNotIsolatingStartsIsolation() throws {
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random()),
            requiresConfirmatoryTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultStartToIsolate(let ack, _, let keySubmissionSupported, let requiresConfirmatory) = state {
            XCTAssertTrue(keySubmissionSupported)
            XCTAssertFalse(requiresConfirmatory)
            _ = ack.acknowledge()
            XCTAssertTrue(isolationContext.isolationStateManager.state.isIsolating)
        } else {
            XCTFail("Unexpected state \(state)")
        }
        
    }
    
    func testPositiveNotAcknowledgedEndOfIsolationWillAcknowledgeEndOfIsolation() throws {
        let date = GregorianDay.today
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(date.advanced(by: -9)),
                onsetDay: nil,
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random()),
            requiresConfirmatoryTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating(let ack, let keySubmissionSupported) = state {
            XCTAssertTrue(keySubmissionSupported)
            _ = ack.acknowledge()
            XCTAssertFalse(isolationContext.isolationStateManager.state.isIsolating)
            XCTAssertTrue(isolationContext.isolationStateStore
                .isolationInfo.hasAcknowledgedEndOfIsolation ?? false)
        } else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testConfirmedPositiveAlreadyOutOfIsolationNoNewIsolation() throws {
        let date = GregorianDay.today
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(date.advanced(by: -15)),
                onsetDay: nil,
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating(let ack, let keySubmissionSupported) = state {
            XCTAssertFalse(keySubmissionSupported)
            ack.acknowledgeWithoutSending()
            XCTAssertFalse(isolationContext.isolationStateManager.state.isIsolating)
        } else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testUnConfirmedPositiveAlreadyOutOfIsolationNoNewIsolation() throws {
        let date = GregorianDay.today
        isolationContext.isolationStateStore.set(
            IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(date.advanced(by: -15)),
                onsetDay: nil,
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .rapidResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random()),
            requiresConfirmatoryTest: true
        )
        
        let state = try makeResultAcknowledgementState(result: result).await().get()
        
        if case TestResultAcknowledgementState.neededForPositiveResultStartToIsolate(let ack, _, let keySubmissionSupported, let requiresConfirmatory) = state {
            XCTAssertTrue(keySubmissionSupported)
            XCTAssertTrue(requiresConfirmatory)
            _ = ack.acknowledge()
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
            requiresConfirmatoryTest: false
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
                isolationTrigger: .selfDiagnosis(date.advanced(by: -9)),
                onsetDay: nil,
                testInfo: nil
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false
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
        
        // store a contact case
        isolationContext.isolationStateStore.set(
            ContactCaseInfo(
                exposureDay: .today,
                isolationFromStartOfDay: .today
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        // confirm the state of the current isolation
        XCTAssertTrue(isolationContext.isolationStateManager.isolationLogicalState.currentValue.activeIsolation!.isContactCaseOnly)
        
        // pull the daily contact termination closure out of the context
        let action = isolationContext.dailyContactTestingEarlyTerminationSupport
        switch action {
        case .enabled(optOutOfIsolation: let actionClosure):
            actionClosure()
        default:
            XCTFail("Expected .enabled to be returned from dailyContactTestingEarlyTerminationSupport")
        }
        
        // confirm that the optOutOfIsolationDay field is set to today
        let contactCaseInfo = isolationContext.isolationStateStore.isolationInfo.contactCaseInfo
        XCTAssertEqual(contactCaseInfo?.optOutOfIsolationDay, .today)
    }
    
    func testOptOutOfIsolationWhenContactCaseOnlyDoesntUpdateOptOutDate() throws {
        
        // store a contact case
        isolationContext.isolationStateStore.set(
            ContactCaseInfo(
                exposureDay: .today,
                isolationFromStartOfDay: .today
            )
        )
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        
        // confirm the state of the current isolation
        XCTAssertTrue(isolationContext.isolationStateManager.isolationLogicalState.currentValue.activeIsolation!.isContactCaseOnly)
        
        // pull the daily contact termination closure out of the context
        let action = isolationContext.dailyContactTestingEarlyTerminationSupport
        switch action {
        case .enabled(optOutOfIsolation: _):
            break
        default:
            XCTFail("Expected .enabled to be returned from dailyContactTestingEarlyTerminationSupport")
        }
        
        // confirm that the optOutOfIsolationDay field is nil
        let contactCaseInfo = isolationContext.isolationStateStore.isolationInfo.contactCaseInfo
        XCTAssertNil(contactCaseInfo?.optOutOfIsolationDay)
    }
}
