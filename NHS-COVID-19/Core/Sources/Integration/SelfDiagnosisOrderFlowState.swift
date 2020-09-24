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
        pasteboardCopier: PasteboardCopying
    ) -> AnyPublisher<SelfDiagnosisOrderFlowState, Never> {
        let testOrdering = CurrentValueSubject<Bool, Never>(false)
        return testOrdering
            .map { value in
                if value {
                    return .testOrdering(VirologyTestingFlowInteractor(
                        virologyTestOrderInfoProvider: context.virologyTestingManager,
                        openURL: context.openURL,
                        pasteboardCopier: pasteboardCopier,
                        acknowledge: nil
                    ))
                } else {
                    return .selfDiagnosis(SelfDiagnosisFlowInteractor(
                        selfDiagnosisManager: context.selfDiagnosisManager!,
                        orderTest: {
                            testOrdering.send(true)
                        },
                        openURL: context.openURL
                    ), isolationState: Interface.IsolationState(domainState: context.isolationState.currentValue, today: LocalDay.today))
                }
            }.eraseToAnyPublisher()
    }
}
