//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum IsolationAcknowledgementState {
    case notNeeded
    case neededForEnd(Isolation, acknowledge: () -> Void)
    case neededForStart(Isolation, acknowledge: () -> Void)
    
    init(logicalState: IsolationLogicalState, now: Date, acknowledgeStart: @escaping () -> Void, acknowledgeEnd: @escaping () -> Void) {
        switch logicalState {
        case .notIsolating:
            self = .notNeeded
        case .isolationFinishedButNotAcknowledged(let isolation):
            self = .neededForEnd(isolation, acknowledge: acknowledgeEnd)
        case .isolating(_, endAcknowledged: true, startAcknowledged: true):
            self = .notNeeded
        case .isolating(let isolation, _, false) where isolation.isContactCaseOnly:
            self = .neededForStart(isolation, acknowledge: acknowledgeStart)
        case .isolating(let isolation, _, _):
            let endDate = isolation.endDate
            let dateToNotify = endDate.advanced(by: -3 * 3600)
            self = (now > dateToNotify) ? .neededForEnd(isolation, acknowledge: acknowledgeEnd) : .notNeeded
        }
    }
}
