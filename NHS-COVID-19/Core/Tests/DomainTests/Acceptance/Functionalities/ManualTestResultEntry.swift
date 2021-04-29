//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
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
    
    func enterPositive(requiresConfirmatoryTest: Bool = false, symptomsOnsetDay: GregorianDay? = nil, endDate: Date? = nil, testKitType: VirologyTestResult.TestKitType = .labResult) throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .positive, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, endDate: endDate ?? currentDateProvider.currentDate)
        if case .askForSymptomsOnsetDay(_, let didFinishAskForSymptomsOnsetDay, let didConfirmSymptoms, let onsetDay) = testResultAcknowledgementState {
            if let symptomsOnsetDay = symptomsOnsetDay {
                didConfirmSymptoms()
                onsetDay(symptomsOnsetDay)
            }
            didFinishAskForSymptomsOnsetDay()
        }
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        
        switch try testResultAcknowledgementStateResult.get() {
        case .neededForPositiveResultStartToIsolate(let acknowledge, _, _),
             .neededForPositiveResultContinueToIsolate(let acknowledge, _, _):
            acknowledge()
        default:
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }
    
    func enterNegative() throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .negative, testKitType: .labResult, requiresConfirmatoryTest: false, endDate: currentDateProvider.currentDate)
        guard case .neededForNegativeResultNotIsolating(let negativeAcknowledgement) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        negativeAcknowledgement()
    }
    
    func enterVoid() throws {
        let testResultAcknowledgementState = try getAcknowledgementState(resultType: .void, testKitType: .labResult, requiresConfirmatoryTest: false, endDate: currentDateProvider.currentDate)
        guard case .neededForVoidResultNotIsolating(let voidAcknowledgement) = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
        voidAcknowledgement()
    }
    
    private func getAcknowledgementState(resultType: VirologyTestResult.TestResult, testKitType: VirologyTestResult.TestKitType, requiresConfirmatoryTest: Bool, endDate: Date) throws -> TestResultAcknowledgementState {
        let result = getTestResult(result: resultType, testKitType: testKitType, endDate: endDate, diagnosisKeySubmissionSupported: !requiresConfirmatoryTest, requiresConfirmatoryTest: requiresConfirmatoryTest)
        apiClient.response(for: "/virology-test/v2/cta-exchange", response: .success(.ok(with: .json(result))))
        let manager = context.virologyTestingManager
        _ = try manager.linkExternalTestResult(with: validToken).await()
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        return try testResultAcknowledgementStateResult.get()
    }
}
