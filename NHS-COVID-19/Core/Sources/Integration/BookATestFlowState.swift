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
        pasteboardCopier: PasteboardCopying
    ) -> AnyPublisher<BookATestFlowState, Never> {
        let testOrdering = CurrentValueSubject<Bool, Never>(false)
        return testOrdering
            .map { value in
                if value {
                    return .testOrdering(VirologyTestingFlowInteractor(
                        virologyTestOrderInfoProvider: context.virologyTestOrderInfoProvider,
                        openURL: context.openURL,
                        pasteboardCopier: pasteboardCopier
                    ))
                } else {
                    return .bookATest(BookATestInfoViewControllerInteractor(
                        didTapBookATest: {
                            testOrdering.send(true)
                        },
                        openURL: context.openURL
                    ))
                }
            }.eraseToAnyPublisher()
    }
}
