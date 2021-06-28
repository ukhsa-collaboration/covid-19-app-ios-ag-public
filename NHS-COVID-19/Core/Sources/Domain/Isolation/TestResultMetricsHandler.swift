//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct TestResultMetricsHandler {
    let currentIsolationState: IsolationLogicalState
    let storedIsolationInfo: IsolationInfo?
    let receivedResult: VirologyStateTestResult
    let configuration: IsolationConfiguration
    
    func trackMetrics() {
        // Check that we already have any result stored
        guard let indexCaseInfo = storedIsolationInfo?.indexCaseInfo,
            let existingTestResult = storedIsolationInfo?.indexCaseInfo?.testInfo else {
            return
        }
        
        // Check that the user is currently isolated or if it's a special case of results added in wrong order
        let isActiveIndexCaseIsolation = currentIsolationState.activeIsolation?.isIndexCase ?? false
        guard isActiveIndexCaseIsolation || unconfirmedPositiveOlderThanExistingNegative(existingTestResult: existingTestResult) else {
            return
        }
        
        // Check if we're interested in the new result
        guard !isolationWouldEndBeforeCurrentIsolationStarted(),
            !rapidResultAfterSymptoms(indexCaseInfo: indexCaseInfo) else {
            return
        }
        
        let oldTest: TestResult
        let newTest: TestResult
        if existingTestResult.assumedTestEndDay < receivedResult.endDay {
            oldTest = TestResult(existingTestResult)
            newTest = TestResult(receivedResult)
        } else {
            oldTest = TestResult(receivedResult)
            newTest = TestResult(existingTestResult)
        }
        
        if oldTest.isNegative ||
            oldTest.testKitType == .labResult ||
            newTest.testKitType != .labResult {
            return
        }
        
        trackMetrics(oldTest: oldTest, newTest: newTest)
    }
    
    private func trackMetrics(oldTest: TestResult, newTest: TestResult) {
        if newTest.isPositive {
            Metrics.signpostPositiveLabAfterPositiveRapidResult(testKitType: oldTest.testKitType)
            return
        } else if newTest.isNegative { // We have to check for negative as it could be void/plod
            Metrics.signpostNegativeLabResultAfterRapidResult(
                testKitType: oldTest.testKitType,
                withinTime: oldTest.isOtherTestWithininConfirmatoryDayLimit(newTest)
            )
        }
    }
    
    private func unconfirmedPositiveOlderThanExistingNegative(existingTestResult: IndexCaseInfo.TestInfo) -> Bool {
        return existingTestResult.result == .negative &&
            receivedResult.endDay < existingTestResult.assumedTestEndDay &&
            receivedResult.requiresConfirmatoryTest
        
    }
    
    private func isolationWouldEndBeforeCurrentIsolationStarted() -> Bool {
        if let isolationStartDay = storedIsolationInfo?.isolationStartDay,
            receivedResult.endDay.advanced(by: configuration.indexCaseSinceNPEXDayNoSelfDiagnosis.days) <= isolationStartDay {
            return true
        }
        return false
    }
    
    private func rapidResultAfterSymptoms(indexCaseInfo: IndexCaseInfo) -> Bool {
        guard let symptomsOnsetDay = indexCaseInfo.symptomaticInfo?.assumedOnsetDay else {
            return false
        }
        
        return receivedResult.testResult == .positive &&
            receivedResult.requiresConfirmatoryTest &&
            symptomsOnsetDay < receivedResult.endDay
        
    }
    
    private struct TestResult {
        var isPositive: Bool
        var isNegative: Bool
        var testKitType: TestKitType?
        var endDay: GregorianDay
        var requiresConfirmatoryTest: Bool
        private var confirmatoryDayLimit: Int?
        
        init(_ testInfo: IndexCaseInfo.TestInfo) {
            isPositive = testInfo.result == .positive
            isNegative = testInfo.result == .negative
            testKitType = testInfo.testKitType
            endDay = testInfo.assumedTestEndDay
            requiresConfirmatoryTest = testInfo.requiresConfirmatoryTest
            confirmatoryDayLimit = testInfo.confirmatoryDayLimit
        }
        
        init(_ virologyResult: VirologyStateTestResult) {
            isPositive = virologyResult.testResult == .positive
            isNegative = virologyResult.testResult == .negative
            testKitType = virologyResult.testKitType
            endDay = virologyResult.endDay
            requiresConfirmatoryTest = virologyResult.requiresConfirmatoryTest
            confirmatoryDayLimit = virologyResult.confirmatoryDayLimit
        }
        
        func isOtherTestWithininConfirmatoryDayLimit(_ otherTest: TestResult) -> Bool {
            guard let confirmatoryDayLimit = confirmatoryDayLimit else { return true }
            return endDay.advanced(by: confirmatoryDayLimit) >= otherTest.endDay
        }
    }
    
}

private extension IndexCaseInfo.TestInfo {
    var assumedTestEndDay: GregorianDay {
        testEndDay ?? receivedOnDay
    }
}
