//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum IsolationState: Equatable {
    case noNeedToIsolate
    case isolate(Isolation)
    
    init(logicalState: IsolationLogicalState) {
        switch logicalState {
        case .notIsolating, .isolationFinishedButNotAcknowledged:
            self = .noNeedToIsolate
        case .isolating(let isolation, _, _):
            self = .isolate(isolation)
        }
    }
}
