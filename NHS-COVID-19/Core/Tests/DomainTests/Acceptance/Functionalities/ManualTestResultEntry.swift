//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import TestSupport
@testable import Domain
@testable import Scenarios

struct ManualTestResultEntry {
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
    
    private let validToken = "f3dzcfdt"
    
    func enterPositive() throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .positive, testKitType: .labResult)
        guard case .neededForPositiveResultStartToIsolate(let positiveAcknowledgement, _, _) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        _ = try positiveAcknowledgement.acknowledge().await()
    }
    
    func enterNegative() throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .negative, testKitType: .labResult)
        guard case .neededForNegativeResultNotIsolating(let negativeAcknowledgement) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        negativeAcknowledgement()
    }
    
    func enterVoid() throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .void, testKitType: .labResult)
        guard case .neededForVoidResultNotIsolating(let voidAcknowledgement) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        voidAcknowledgement()
    }
    
    private func getAcknowledgementState(resultType: VirologyTestResult.TestResult, testKitType: VirologyTestResult.TestKitType) throws -> TestResultAcknowledgementState {
        let result = getTestResult(result: resultType, testKitType: testKitType, endDate: currentDateProvider.currentDate, diagnosisKeySubmissionSupported: true)
        apiClient.response(for: "/virology-test/v2/cta-exchange", response: .success(.ok(with: .json(result))))
        let manager = context.virologyTestingManager
        _ = try manager.linkExternalTestResult(with: validToken).await()
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        return try testResultAcknowledgementStateResult.get()
    }
}
