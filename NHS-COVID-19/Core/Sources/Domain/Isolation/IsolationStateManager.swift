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
    var state: IsolationLogicalState {
        didSet {
            if state.isIsolating, !oldValue.isIsolating {
                Metrics.signpost(.startedIsolation)
            }
        }
    }
    
    var isolationLogicalState: DomainProperty<IsolationLogicalState>
    
    init<InfoPublisher: Publisher, TodayPublisher: Publisher>(
        isolationStateInfo: InfoPublisher,
        day: TodayPublisher,
        calculateState: @escaping (IsolationStateInfo?, LocalDay) -> IsolationLogicalState
    ) where
        InfoPublisher.Output == IsolationStateInfo?, InfoPublisher.Failure == Never,
        TodayPublisher.Output == LocalDay, TodayPublisher.Failure == Never {
        isolationLogicalState = isolationStateInfo.combineLatest(day)
            .map(calculateState).domainProperty()
        state = isolationLogicalState.currentValue
        cancellable = isolationLogicalState
            .sink { [weak self] state in
                self?.state = state
            }
    }
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        switch state {
        case .isolating(let isolation, _, _):
            switch isolation.reason {
            case .indexCase(let hasPositiveTestResult, let testKitType, let isSelfDiagnosed):
                if hasPositiveTestResult {
                    if let testType = testKitType {
                        switch testType {
                        case .labResult:
                            Metrics.signpost(.isolatedForTestedPositiveBackgroundTick)
                        case .rapidResult, .rapidSelfReported:
                            Metrics.signpost(.isIsolatingForTestedLFDPositiveBackgroundTick)
                        }
                    } else {
                        Metrics.signpost(.isolatedForTestedPositiveBackgroundTick)
                    }
                }
                if isSelfDiagnosed {
                    Metrics.signpost(.isolatedForSelfDiagnosedBackgroundTick)
                }
            case .contactCase:
                Metrics.signpost(.isolatedForHadRiskyContactBackgroundTick)
            case .bothCases(let hasPositiveTestResult, let testKitType, let isSelfDiagnosed):
                Metrics.signpost(.isolatedForHadRiskyContactBackgroundTick)
                if hasPositiveTestResult {
                    if let testType = testKitType {
                        switch testType {
                        case .labResult:
                            Metrics.signpost(.isolatedForTestedPositiveBackgroundTick)
                        case .rapidResult, .rapidSelfReported:
                            Metrics.signpost(.isIsolatingForTestedLFDPositiveBackgroundTick)
                        }
                    } else {
                        Metrics.signpost(.isolatedForTestedPositiveBackgroundTick)
                    }
                }
                if isSelfDiagnosed {
                    Metrics.signpost(.isolatedForSelfDiagnosedBackgroundTick)
                }
            }
            Metrics.signpost(.isolationBackgroundTick)
        default:
            break
        }
        
        return Empty().eraseToAnyPublisher()
    }
    
}

extension IsolationStateManager {
    
    convenience init(stateStore: IsolationStateStore, currentDateProvider: DateProviding) {
        self.init(
            isolationStateInfo: stateStore.$isolationStateInfo,
            day: currentDateProvider.today,
            calculateState: IsolationLogicalState.init
        )
    }
    
}
