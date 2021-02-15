//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct TestResultIsolationOperation {
    let currentIsolationState: IsolationLogicalState
    let storedIsolationInfo: IsolationInfo
    let result: VirologyStateTestResult
    
    func storeOperation() -> IsolationStateStore.Operation {
        switch result.testResult {
        case .void: return .nothing
        case .negative:
            guard let indexCaseInfo = storedIsolationInfo.indexCaseInfo else {
                return .overwrite
            }
            
            switch indexCaseInfo.testInfo?.result {
            case .none, .void: return .update
            case .negative: return .nothing
            case .positive where indexCaseInfo.testInfo?.confirmationStatus == .pending: return .overwrite
            case .positive: return .nothing
            }
        case .positive where result.requiresConfirmatoryTest:
            if currentIsolationState.activeIsolation?.isIndexCase ?? false {
                return .nothing
            } else {
                return .overwrite
            }
        case .positive:
            guard let indexCaseInfo = storedIsolationInfo.indexCaseInfo else {
                return .overwrite
            }
            
            switch indexCaseInfo.testInfo?.result {
            case .none, .void: return .update
            case .negative: return .overwrite
            case .positive where indexCaseInfo.testInfo?.confirmationStatus == .pending: return .confirm
            case .positive: return .nothing
            }
        }
    }
}
