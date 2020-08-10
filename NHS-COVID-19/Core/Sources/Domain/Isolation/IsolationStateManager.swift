//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import UIKit

class IsolationStateManager {
    
    private var cancellable: AnyCancellable?
    
    @Published
    var state: IsolationLogicalState = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
    
    init<InfoPublisher: Publisher, TodayPublisher: Publisher>(
        isolationStateInfo: InfoPublisher,
        day: TodayPublisher,
        calculateState: @escaping (IsolationStateInfo?, LocalDay) -> IsolationLogicalState
    ) where
        InfoPublisher.Output == IsolationStateInfo?, InfoPublisher.Failure == Never,
        TodayPublisher.Output == LocalDay, TodayPublisher.Failure == Never {
        cancellable = isolationStateInfo.combineLatest(day)
            .map(calculateState)
            .sink { [weak self] state in
                self?.state = state
            }
    }
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        switch state {
        case .isolating:
            Metrics.signpost(.isolationBackgroundTick)
        default:
            break
        }
        
        return Empty().eraseToAnyPublisher()
    }
    
}

extension IsolationStateManager {
    
    convenience init(stateStore: IsolationStateStore, notificationCenter: NotificationCenter) {
        self.init(
            isolationStateInfo: stateStore.$isolationStateInfo,
            day: notificationCenter.today,
            calculateState: IsolationLogicalState.init
        )
    }
    
}

private extension IsolationLogicalState {
    init(stateInfo: IsolationStateInfo?, day: LocalDay) {
        guard let stateInfo = stateInfo else {
            self = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
            return
        }
        
        self.init(
            today: day,
            info: stateInfo.isolationInfo,
            configuration: stateInfo.configuration
        )
    }
}
