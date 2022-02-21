//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import XCTest
@testable import Domain

class TestResultAcknowledgementStateTests: XCTestCase {
    var indexCaseInfo: IndexCaseInfo!
    
    override func setUp() {
        indexCaseInfo = IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: .today, onsetDay: nil),
            testInfo: nil
        )
    }
    
    func testPositiveIsolating() throws {
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: false
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultStartToIsolate = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testPositiveIsolatingNoSubmissionToken() throws {
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: false
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultStartToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testPositiveNotAcknowledgedEndOfIsolation() {
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolationFinishedButNotAcknowledged(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating = state {} else {
            XCTFail()
        }
    }
    
    func testPositiveNotIsolating() {
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testPositiveNotIsolatingNoSubmissionToken() {
        let result = VirologyStateTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil,
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating = state {} else {
            XCTFail()
        }
    }
    
    func testNegativeIsolatingDueToContactCase() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(contactCaseInfo: Isolation.ContactCaseInfo(exposureDay: .today))),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: true
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: isolationState,
            indexCaseInfo: nil,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForNegativeResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testNegativeIsolatingDueToSelfDiagnosis() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: false
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: isolationState,
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForNegativeAfterPositiveResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testNegativeNotAcknowledgedEndOfIsolation() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolationFinishedButNotAcknowledged(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForNegativeResultNotIsolating = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testNegativeNotIsolating() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForNegativeResultNotIsolating = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testNegativeAfterPositiveIsolating() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: false
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: isolationState,
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForNegativeAfterPositiveResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testVoidIsolating() {
        let result = VirologyStateTestResult(
            testResult: .void,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: false
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForVoidResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testVoidNotIsolating() {
        let result = VirologyStateTestResult(
            testResult: .void,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForVoidResultNotIsolating = state {} else {
            XCTFail()
        }
    }
    
    func testPlodTestResult() {
        let result = VirologyStateTestResult(
            testResult: .plod,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForPlodResult = state {} else {
            XCTFail()
        }
    }
    
    func testVoidNotAcknowledgedEndOfIsolation() {
        let result = VirologyStateTestResult(
            testResult: .void,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolationFinishedButNotAcknowledged(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForVoidResultNotIsolating = state {} else {
            XCTFail()
        }
    }
    
    func testNegativeAfterUnconfirmedPositive() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: true, testKitType: nil, isSelfDiagnosed: false, isPendingConfirmation: true), contactCaseInfo: nil)),
            endAcknowledged: false,
            startOfContactIsolationAcknowledged: false
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: isolationState,
            indexCaseInfo: indexCaseInfo,
            completionHandler: {}
        )
        
        if case TestResultAcknowledgementState.neededForNegativeResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
}
