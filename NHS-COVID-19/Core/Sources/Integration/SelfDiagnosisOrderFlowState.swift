//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

enum SelfDiagnosisOrderFlowState {
    case selfDiagnosis(SelfDiagnosisFlowViewController.Interacting)
    case testOrdering(VirologyTestingFlowViewController.Interacting)
    
    static func makeState(context: RunningAppContext) -> AnyPublisher<SelfDiagnosisOrderFlowState, Never> {
        let testOrdering = CurrentValueSubject<Bool, Never>(false)
        return testOrdering
            .map { value in
                if value {
                    return .testOrdering(VirologyTestingFlowInteractor(
                        virologyTestOrderInfoProvider: context.virologyTestingManager,
                        openURL: context.openURL,
                        acknowledge: nil
                    ))
                } else {
                    return .selfDiagnosis(SelfDiagnosisFlowInteractor(
                        selfDiagnosisManager: context.selfDiagnosisManager,
                        orderTest: {
                            testOrdering.send(true)
                        },
                        openURL: context.openURL,
                        initialIsolationState: Interface.IsolationState(domainState: context.isolationState.currentValue, today: LocalDay.today)
                    ))
                }
            }.eraseToAnyPublisher()
    }
}
