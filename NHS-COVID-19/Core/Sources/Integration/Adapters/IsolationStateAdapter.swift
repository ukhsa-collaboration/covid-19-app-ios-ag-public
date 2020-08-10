//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

extension Publisher where Output == Domain.IsolationState, Failure == Never {
    
    func mapToInterface(with notificationCenter: NotificationCenter) -> AnyPublisher<Interface.IsolationState, Never> {
        combineLatest(notificationCenter.today)
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
            self = .isolating(days: today.daysRemaining(until: isolation.endDate), endDate: isolation.endDate)
        }
    }
    
}
