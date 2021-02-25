//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum IsolationState: Equatable {
    case noNeedToIsolate(optOutOfIsolationDay: Date? = nil)
    case isolate(Isolation)
    
    init(logicalState: IsolationLogicalState) {
        switch logicalState {
        case .notIsolating(let isolation):
            self = .noNeedToIsolate(optOutOfIsolationDay: isolation?.reason.contactCaseInfo?.optOutOfIsolationDay?.startDate(in: .current))
        case .isolationFinishedButNotAcknowledged:
            self = .noNeedToIsolate()
        case .isolating(let isolation, _, _):
            self = .isolate(isolation)
        }
    }
}
