//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum IsolationAcknowledgementState {
    case notNeeded
    case neededForEnd(Isolation, acknowledge: () -> Void)
    case neededForStartContactIsolation(Isolation, acknowledge: (Bool) -> Void)

    init(logicalState: IsolationLogicalState, now: Date, acknowledgeStart: @escaping (Bool) -> Void, acknowledgeEnd: @escaping () -> Void) {
        switch logicalState {
        case .notIsolating:
            self = .notNeeded
        case .isolationFinishedButNotAcknowledged(let isolation):
            self = .neededForEnd(isolation, acknowledge: acknowledgeEnd)
        case .isolating(_, endAcknowledged: true, _):
            self = .notNeeded
        case .isolating(let isolation, _, false) where isolation.isContactCase:
            self = .neededForStartContactIsolation(isolation, acknowledge: acknowledgeStart)
        case .isolating(let isolation, _, _):
            let endDate = isolation.endDate
            let dateToNotify = endDate.advanced(by: -3 * 3600)
            self = (now > dateToNotify) ? .neededForEnd(isolation, acknowledge: acknowledgeEnd) : .notNeeded
        }
    }
}
