//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import TestSupport
@testable import Scenarios
@testable import Domain

struct PollingTestResult {
    private let context: RunningAppContext
    private let apiClient: MockHTTPClient
    private let currentDateProvider: AcceptanceTestMockDateProvider
    
    init(
        configuration: AcceptanceTestCase.Instance.Configuration,
        context: RunningAppContext
    ) {
        self.apiClient = configuration.apiClient
        self.currentDateProvider = configuration.currentDateProvider
        self.context = context
    }
    
    func receivePositiveAndAcknowledge(runBackgroundTasks: @escaping () -> Void) throws {
        let testResultAcknowledgementState = try receiveResultAndGetAcknowledgementState(resultType: .positive, runBackgroundTasks: runBackgroundTasks)
        guard case .neededForPositiveResultContinueToIsolate(let positiveAcknowledgement, _) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        _ = try positiveAcknowledgement.acknowledge().await()
        apiClient.reset()
    }
    
    func receiveNegativeAndAcknowledge(runBackgroundTasks: @escaping () -> Void) throws {
        let testResultAcknowledgementState = try receiveResultAndGetAcknowledgementState(resultType: .negative, runBackgroundTasks: runBackgroundTasks)
        guard case .neededForNegativeResultNotIsolating(let acknowledge) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        acknowledge()
        apiClient.reset()
    }
    
    func receiveVoidAndAcknowledge(runBackgroundTasks: @escaping () -> Void) throws {
        let testResultAcknowledgementState = try receiveResultAndGetAcknowledgementState(resultType: .void, runBackgroundTasks: runBackgroundTasks)
        guard case .neededForVoidResultContinueToIsolate(let acknowledge, _) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        acknowledge()
        apiClient.reset()
    }
    
    private func receiveResultAndGetAcknowledgementState(resultType: VirologyTestResult.TestResult, runBackgroundTasks: @escaping () -> Void) throws -> TestResultAcknowledgementState {
        stubResultsEndpoint(resultType: resultType)
        runBackgroundTasks()
        return try getTestResultAcknowledgementState()
    }
    
    private func stubResultsEndpoint(resultType: VirologyTestResult.TestResult) {
        let testResult = getTestResult(result: resultType, endDate: currentDateProvider.currentDate)
        apiClient.response(for: "/virology-test/results", response: .success(.ok(with: .json(testResult))))
    }
    
    private func getTestResultAcknowledgementState() throws -> TestResultAcknowledgementState {
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        return try testResultAcknowledgementStateResult.get()
    }
}
