//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

enum SelfDiagnosisOrderFlowState {
    case selfDiagnosis(SelfDiagnosisFlowViewController.Interacting, isolationState: Interface.IsolationState)
    case testOrdering(VirologyTestingFlowViewController.Interacting)
    
    static func makeState(
        context: RunningAppContext,
        coordinator: ApplicationCoordinator
    ) -> AnyPublisher<SelfDiagnosisOrderFlowState, Never> {
        let testOrdering = CurrentValueSubject<Bool, Never>(false)
        return testOrdering
            .map { value in
                if value {
                    return .testOrdering(VirologyTestingFlowInteractor(
                        virologyTestOrderInfoProvider: context.virologyTestOrderInfoProvider,
                        externalLinkOpener: coordinator,
                        pasteboardCopier: coordinator
                    ))
                } else {
                    return .selfDiagnosis(SelfDiagnosisFlowInteractor(
                        selfDiagnosisManager: context.selfDiagnosisManager!,
                        coordinator: coordinator,
                        orderTest: {
                            testOrdering.send(true)
                        },
                        externalLinkOpener: coordinator
                    ), isolationState: Interface.IsolationState(domainState: context.isolationState.currentValue, today: LocalDay.today))
                }
            }.eraseToAnyPublisher()
    }
}
