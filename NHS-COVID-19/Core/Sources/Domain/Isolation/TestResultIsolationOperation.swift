//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct TestResultIsolationOperation {
    let currentIsolationState: IsolationLogicalState
    let storedIsolationInfo: IsolationInfo?
    let result: VirologyStateTestResult
    let configuration: IsolationConfiguration
    
    private func storeOperationGivenSymptomaticAfterPositive() -> IsolationStateStore.Operation {
        guard let indexCaseInfo = storedIsolationInfo?.indexCaseInfo,
            let symptomaticInfo = indexCaseInfo.symptomaticInfo,
            let testInfo = indexCaseInfo.testInfo else {
            preconditionFailure("No exisiting test found for symptomatic after positive")
        }
        
        let testOlderThanAssumedOnsetDay = result.endDay < symptomaticInfo.assumedOnsetDay
        
        switch result.testResult {
        case .void, .plod: return .nothing
        case .negative:
            let existingTestEndDay = indexCaseInfo.assumedTestEndDay ?? testInfo.receivedOnDay
            let testOlderThanAssumedOnsetDay = result.endDay < symptomaticInfo.assumedOnsetDay
            
            switch testInfo.confirmationStatus {
            case .pending:
                if result.endDay < existingTestEndDay {
                    return .nothing
                } else if let dayLimit = testInfo.confirmatoryDayLimit,
                    existingTestEndDay.advanced(by: dayLimit) < result.endDay {
                    return testOlderThanAssumedOnsetDay ? .complete : .completeAndDeleteSymptoms
                } else {
                    return testOlderThanAssumedOnsetDay ? .deleteTest : .update
                }
            case .notRequired, .confirmed:
                return testOlderThanAssumedOnsetDay ? .nothing : .deleteSymptoms
            }
        case .positive:
            // The new result is older than the already stored result
            if result.endDay.distance(to: testInfo.testEndDay ?? testInfo.receivedOnDay) > 0 {
                if result.requiresConfirmatoryTest, testInfo.confirmationStatus != .pending {
                    return .updateAndConfirm
                } else {
                    return .update
                }
            }
            
            // The new result is newer than the already stored result but older than symptoms
            if testOlderThanAssumedOnsetDay {
                if !result.requiresConfirmatoryTest, testInfo.confirmationStatus == .pending {
                    return .confirm
                } else {
                    return .nothing
                }
            }
            
            // The new result is newer than symptoms
            if result.requiresConfirmatoryTest {
                if currentIsolationState.activeIsolation?.isIndexCase ?? false {
                    return .nothing
                } else {
                    return .overwrite
                }
            } else {
                return .update
            }
        }
    }
    
    func storeOperation() -> IsolationStateStore.Operation {
        switch result.testResult {
        case .void, .plod: return .nothing
        case .negative:
            guard let indexCaseInfo = storedIsolationInfo?.indexCaseInfo else {
                return .overwrite
            }
            
            if indexCaseInfo.hasBecomeSymptomaticAfterPositive {
                return storeOperationGivenSymptomaticAfterPositive()
            }
            
            switch indexCaseInfo.testInfo?.result {
            case .none:
                if let onsetDay = indexCaseInfo.symptomaticInfo?.assumedOnsetDay, result.endDay < onsetDay {
                    return .nothing
                } else {
                    return .update
                }
            case .negative: return .nothing
            case .positive where indexCaseInfo.testInfo?.confirmationStatus == .pending:
                if result.endDay < indexCaseInfo.startDay {
                    // The test result we received is from before the start of
                    // the current isolation
                    return .nothing
                } else if let dayLimit = indexCaseInfo.testInfo?.confirmatoryDayLimit,
                    let existingEndDate = indexCaseInfo.assumedTestEndDay,
                    existingEndDate.advanced(by: dayLimit) < result.endDay {
                    // The negative test result we got is too late, and outside
                    // the `confirmatoryDayLimit` to store the negative result.
                    
                    return .complete
                } else {
                    // The test result was within the time limit, so we store
                    // the negative test.
                    
                    return .update
                }
            case .positive: return .nothing
            }
        case .positive:
            if let isolationStartDay = storedIsolationInfo?.isolationStartDay,
                result.endDay.advanced(by: configuration.indexCaseSinceNPEXDayNoSelfDiagnosis.days) <= isolationStartDay {
                return .ignore
            }
            
            guard let indexCaseInfo = storedIsolationInfo?.indexCaseInfo else {
                return .overwrite
            }
            
            if indexCaseInfo.hasBecomeSymptomaticAfterPositive {
                return storeOperationGivenSymptomaticAfterPositive()
            }
            
            // The new test is before symptoms and before stored test
            if let onsetDay = indexCaseInfo.symptomaticInfo?.assumedOnsetDay,
                result.endDay < onsetDay,
                indexCaseInfo.testInfo?.result != .negative {
                if result.requiresConfirmatoryTest, let testInfo = indexCaseInfo.testInfo, testInfo.confirmationStatus != .pending {
                    return .updateAndConfirm
                } else {
                    return .update
                }
            }
            
            if let endDay = indexCaseInfo.assumedTestEndDay,
                indexCaseInfo.testInfo?.result == .positive,
                result.endDay < endDay {
                switch indexCaseInfo.isolationTrigger {
                case .manualTestEntry:
                    if result.requiresConfirmatoryTest, let testInfo = indexCaseInfo.testInfo, testInfo.confirmationStatus != .pending {
                        return .overwriteAndConfirm
                    } else {
                        return .overwrite
                    }
                case .selfDiagnosis:
                    if result.requiresConfirmatoryTest, let testInfo = indexCaseInfo.testInfo, testInfo.confirmationStatus != .pending {
                        return .updateAndConfirm
                    } else {
                        return .update
                    }
                }
            }
            
            if let endDay = indexCaseInfo.assumedTestEndDay,
                indexCaseInfo.testInfo?.result == .negative,
                result.endDay < endDay {
                if result.requiresConfirmatoryTest {
                    if let onsetDay = indexCaseInfo.symptomaticInfo?.assumedOnsetDay, result.endDay > onsetDay {
                        return .ignore
                    } else if let confirmatoryDayLimit = result.confirmatoryDayLimit,
                        result.endDay.advanced(by: confirmatoryDayLimit) < endDay {
                        return .overwriteAndComplete
                    } else {
                        return .ignore
                    }
                } else {
                    switch indexCaseInfo.isolationTrigger {
                    case .manualTestEntry:
                        return .overwrite
                    case .selfDiagnosis:
                        return .update
                    }
                }
            }
            
            if result.requiresConfirmatoryTest {
                if currentIsolationState.activeIsolation?.isIndexCase ?? false {
                    return .nothing
                } else {
                    return .overwrite
                }
            } else {
                switch indexCaseInfo.testInfo?.result {
                case .none: return .update
                case .negative: return .overwrite
                case .positive where indexCaseInfo.testInfo?.confirmationStatus == .pending: return .confirm
                case .positive: return .nothing
                }
            }
        }
    }
}
