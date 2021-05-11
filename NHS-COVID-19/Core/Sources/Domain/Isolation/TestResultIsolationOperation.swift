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
    
    func storeOperation() -> IsolationStateStore.Operation {
        switch result.testResult {
        case .void: return .nothing
        case .negative:
            guard let indexCaseInfo = storedIsolationInfo?.indexCaseInfo else {
                return .overwrite
            }
            
            switch indexCaseInfo.testInfo?.result {
            case .none, .void:
                if let onsetDay = indexCaseInfo.assumedOnsetDayForSelfDiagnosis, result.endDay < onsetDay {
                    return .nothing
                } else {
                    return .update
                }
            case .negative: return .nothing
            case .positive where indexCaseInfo.testInfo?.confirmationStatus == .pending:
                if result.endDay < indexCaseInfo.startDay {
                    return .nothing
                } else {
                    return .overwrite
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
            
            if let onsetDay = indexCaseInfo.assumedOnsetDayForSelfDiagnosis, result.endDay < onsetDay {
                if result.requiresConfirmatoryTest, let testInfo = indexCaseInfo.testInfo, testInfo.confirmationStatus != .pending {
                    return .overwriteAndConfirm
                } else {
                    return .overwrite
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
                    return .ignore
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
                case .none, .void: return .update
                case .negative: return .overwrite
                case .positive where indexCaseInfo.testInfo?.confirmationStatus == .pending: return .confirm
                case .positive: return .nothing
                }
            }
        }
    }
}
