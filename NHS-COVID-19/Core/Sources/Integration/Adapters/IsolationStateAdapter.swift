//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

extension Publisher where Output == Domain.IsolationState, Failure == Never {
    
    func mapToInterface(with currentDateProvider: DateProviding) -> AnyPublisher<Interface.IsolationState, Never> {
        combineLatest(currentDateProvider.today)
            .map(Interface.IsolationState.init)
            .eraseToAnyPublisher()
    }
    
}

extension Interface.IsolationState {
    
    init(domainState: Domain.IsolationState, today: LocalDay) {
        switch domainState {
        case .noNeedToIsolate:
            self = .notIsolating
        case .isolate(let isolation):
            let duration = isolation.fromDay.gregorianDay.distance(to: isolation.untilStartOfDay.gregorianDay)
            let daysRemaining = today.daysRemaining(until: isolation.endDate)
            let percentRemaining = Self.percentRemaining(duration: duration, daysRemaining: daysRemaining)
            self = .isolating(days: daysRemaining, percentRemaining: percentRemaining, endDate: isolation.endDate, hasPositiveTest: isolation.hasPositiveTestResult)
        }
    }
    
    private static func percentRemaining(duration: Int, daysRemaining: Int) -> Double {
        if duration <= 0 { return 0 }
        let percentRemaining = Double(daysRemaining) / Double(duration)
        return max(0, min(percentRemaining, 1))
    }
}
