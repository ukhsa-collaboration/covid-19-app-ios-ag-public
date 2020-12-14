//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import XCTest
@testable import Domain

class TestResultAcknowledgementStateTests: XCTestCase {
    var positiveAcknowledgement: TestResultAcknowledgementState.PositiveAcknowledgement!
    var indexCaseInfo: IndexCaseInfo!
    
    override func setUp() {
        positiveAcknowledgement = { _, _, _, _ in
            TestResultAcknowledgementState.PositiveResultAcknowledgement(
                acknowledge: { Empty().eraseToAnyPublisher() },
                acknowledgeWithoutSending: {}
            )
            
        }
        indexCaseInfo = IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(.today),
            onsetDay: nil,
            testInfo: nil
        )
    }
    
    func testPositiveIsolating() throws {
        let result = VirologyStateTestResult(
            testResult: .positive,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)),
            endAcknowledged: false,
            startAcknowledged: true
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultStartToIsolate = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testPositiveIsolatingNoSubmissionToken() throws {
        let result = VirologyStateTestResult(
            testResult: .positive,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)),
            endAcknowledged: false,
            startAcknowledged: true
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.notNeeded = state {} else {
            XCTFail()
        }
    }
    
    func testPositiveNotAcknowledgedEndOfIsolation() {
        let result = VirologyStateTestResult(
            testResult: .positive,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.isolationFinishedButNotAcknowledged(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true))
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating = state {} else {
            XCTFail()
        }
    }
    
    func testPositiveNotIsolating() {
        let result = VirologyStateTestResult(
            testResult: .positive,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForPositiveResultNotIsolating = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testPositiveNotIsolatingNoSubmissionToken() {
        let result = VirologyStateTestResult(
            testResult: .positive,
            endDate: Date(),
            diagnosisKeySubmissionToken: nil
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.notNeeded = state {} else {
            XCTFail()
        }
    }
    
    func testNegativeIsolating() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)),
            endAcknowledged: false,
            startAcknowledged: true
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForNegativeResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testNegativeNotAcknowledgedEndOfIsolation() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.isolationFinishedButNotAcknowledged(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true))
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForNegativeResultNotIsolating = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testNegativeNotIsolating() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForNegativeResultNotIsolating = state {} else {
            XCTFail("Unexpected state \(state)")
        }
    }
    
    func testNegativeAfterPositiveIsolating() {
        let result = VirologyStateTestResult(
            testResult: .negative,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true)),
            endAcknowledged: false,
            startAcknowledged: true
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: isolationState,
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForNegativeAfterPositiveResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testVoidIsolating() {
        let result = VirologyStateTestResult(
            testResult: .void,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.isolating(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)),
            endAcknowledged: false,
            startAcknowledged: true
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForVoidResultContinueToIsolate = state {} else {
            XCTFail()
        }
    }
    
    func testVoidNotIsolating() {
        let result = VirologyStateTestResult(
            testResult: .void,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForVoidResultNotIsolating = state {} else {
            XCTFail()
        }
    }
    
    func testVoidNotAcknowledgedEndOfIsolation() {
        let result = VirologyStateTestResult(
            testResult: .void,
            endDate: Date(),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
        
        let isolationState = IsolationLogicalState.isolationFinishedButNotAcknowledged(
            Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true))
        )
        
        let state = TestResultAcknowledgementState(
            result: result,
            newIsolationState: isolationState,
            currentIsolationState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            indexCaseInfo: indexCaseInfo,
            positiveAcknowledgement: positiveAcknowledgement,
            completionHandler: { _ in }
        )
        
        if case TestResultAcknowledgementState.neededForVoidResultNotIsolating = state {} else {
            XCTFail()
        }
    }
}
