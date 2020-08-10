//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

enum BookATestFlowState {
    case bookATest(BookATestInfoViewController.Interacting)
    case testOrdering(VirologyTestingFlowViewController.Interacting)
    
    static func makeState(
        context: RunningAppContext,
        coordinator: ApplicationCoordinator
    ) -> AnyPublisher<BookATestFlowState, Never> {
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
                    return .bookATest(BookATestInfoViewControllerInteractor(
                        didTapBookATest: {
                            testOrdering.send(true)
                        },
                        openExternalLink: coordinator.openInBrowser
                    ))
                }
            }.eraseToAnyPublisher()
    }
}
