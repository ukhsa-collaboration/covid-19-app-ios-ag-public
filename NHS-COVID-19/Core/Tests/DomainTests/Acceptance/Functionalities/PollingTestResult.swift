//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import TestSupport
@testable import Domain
@testable import Scenarios

struct PollingTestResult {
    private let context: RunningAppContext
    private let apiClient: MockHTTPClient
    private let currentDateProvider: AcceptanceTestMockDateProvider
    
    init(
        configuration: AcceptanceTestCase.Instance.Configuration,
        context: RunningAppContext
    ) {
        apiClient = configuration.apiClient
        currentDateProvider = configuration.currentDateProvider
        self.context = context
    }
    
    func receivePositiveAndAcknowledge(testKitType: VirologyTestResult.TestKitType = .labResult, runBackgroundTasks: @escaping () -> Void) throws {
        let testResultAcknowledgementState = try receiveResultAndGetAcknowledgementState(resultType: .positive, testKitType: testKitType, diagnosisKeySubmissionSupported: true, requiresConfirmatoryTest: false, runBackgroundTasks: runBackgroundTasks)
        guard case .neededForPositiveResultContinueToIsolate(let positiveAcknowledgement, _, _, _) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        _ = try positiveAcknowledgement.acknowledge().await()
        apiClient.reset()
    }
    
    func receiveNegativeAndAcknowledge(runBackgroundTasks: @escaping () -> Void) throws {
        let testResultAcknowledgementState = try receiveResultAndGetAcknowledgementState(resultType: .negative, testKitType: .labResult, diagnosisKeySubmissionSupported: true, requiresConfirmatoryTest: false, runBackgroundTasks: runBackgroundTasks)
        guard case .neededForNegativeResultNotIsolating(let acknowledge) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        acknowledge()
        apiClient.reset()
    }
    
    func receiveVoidAndAcknowledge(runBackgroundTasks: @escaping () -> Void) throws {
        let testResultAcknowledgementState = try receiveResultAndGetAcknowledgementState(resultType: .void, testKitType: .labResult, diagnosisKeySubmissionSupported: true, requiresConfirmatoryTest: false, runBackgroundTasks: runBackgroundTasks)
        guard case .neededForVoidResultContinueToIsolate(let acknowledge, _) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        acknowledge()
        apiClient.reset()
    }
    
    private func receiveResultAndGetAcknowledgementState(resultType: VirologyTestResult.TestResult, testKitType: VirologyTestResult.TestKitType, diagnosisKeySubmissionSupported: Bool, requiresConfirmatoryTest: Bool, runBackgroundTasks: @escaping () -> Void) throws -> TestResultAcknowledgementState {
        stubResultsEndpoint(resultType: resultType, testKitType: testKitType, diagnosisKeySubmissionSupported: diagnosisKeySubmissionSupported, requiresConfirmatoryTest: requiresConfirmatoryTest)
        runBackgroundTasks()
        return try getTestResultAcknowledgementState()
    }
    
    private func stubResultsEndpoint(resultType: VirologyTestResult.TestResult, testKitType: VirologyTestResult.TestKitType, diagnosisKeySubmissionSupported: Bool, requiresConfirmatoryTest: Bool) {
        let testResult = getTestResult(result: resultType, testKitType: testKitType, endDate: currentDateProvider.currentDate, diagnosisKeySubmissionSupported: diagnosisKeySubmissionSupported, requiresConfirmatoryTest: requiresConfirmatoryTest)
        apiClient.response(for: "/virology-test/v2/results", response: .success(.ok(with: .json(testResult))))
    }
    
    private func getTestResultAcknowledgementState() throws -> TestResultAcknowledgementState {
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        return try testResultAcknowledgementStateResult.get()
    }
}
