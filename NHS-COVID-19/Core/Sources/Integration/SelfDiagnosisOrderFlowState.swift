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

    static func makeState(context: RunningAppContext, acknowledge: (() -> Void)? = nil) -> AnyPublisher<SelfDiagnosisOrderFlowState, Never> {
        let testOrdering = CurrentValueSubject<Bool, Never>(false)
        return testOrdering
            .map { value in
                if value {
                    return .testOrdering(VirologyTestingFlowInteractor(
                        virologyTestOrderInfoProvider: context.virologyTestingManager,
                        openURL: context.openURL,
                        acknowledge: acknowledge
                    ))
                } else {
                    return .selfDiagnosis(SelfDiagnosisFlowInteractor(
                        selfDiagnosisManager: context.selfDiagnosisManager,
                        orderTest: {
                            testOrdering.send(true)
                        },
                        openURL: context.openURL,
                        initialIsolationState: context.isolationState.currentValue
                    ))
                }
            }.eraseToAnyPublisher()
    }
}
