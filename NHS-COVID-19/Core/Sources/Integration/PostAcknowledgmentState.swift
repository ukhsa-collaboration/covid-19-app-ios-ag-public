//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

enum PostAcknowledgmentState {
    case home
    case keySharing(DiagnosisKeySharer, SendKeysFlowViewController.ShareFlowType)
    case followUpTest
    case contactCase(ContactCaseResultInterfaceState)
    case thankYou(ThankYouViewController.ViewType)
    case bookATest
    case warnAndBookATest
    
    static func makePostAcknowledgmentState(
        showUIState: CurrentValueSubject<PostAcknowledgementViewController.UITriggeredInterfaceState?, Never>,
        diagnosisKeySharer: DomainProperty<DiagnosisKeySharer?>,
        virologyTestingManager: VirologyTestingManaging
    ) -> AnyPublisher<PostAcknowledgmentState, Never> {
        showUIState
            .combineLatest(diagnosisKeySharer, virologyTestingManager.isFollowUpTestRequired())
            .receive(on: UIScheduler.shared)
            .map { combinedState in
                // (showUIState, diagnosisKeySharer, isFollowUpTestRequired)
                let showUIState = combinedState.0
                let diagnosisKeySharer = combinedState.1
                let isFollowUpTestRequired = combinedState.2
                
                if let showUIState = showUIState {
                    switch showUIState {
                    case .showBookATest: return .bookATest
                    case .showWarnAndBookATest: return .warnAndBookATest
                    case .showContactCaseResult(let result): return .contactCase(result)
                    case .thankYou:
                        return .thankYou(isFollowUpTestRequired ? .stillNeedToBookATest : .completed)
                    }
                } else if let diagnosisKeySharer = diagnosisKeySharer,
                    let shareFlowType = SendKeysFlowViewController.ShareFlowType(
                        hasFinishedInitialKeySharingFlow: diagnosisKeySharer.hasFinishedInitialKeySharingFlow,
                        hasTriggeredReminderNotification: diagnosisKeySharer.hasTriggeredReminderNotification
                    ) {
                    return .keySharing(diagnosisKeySharer, shareFlowType)
                } else if isFollowUpTestRequired {
                    return .followUpTest
                } else {
                    return .home
                }
            }
            .removeDuplicates(by: { lhs, rhs in
                switch (lhs, rhs) {
                case (.home, .home),
                     (.keySharing, .keySharing),
                     (.followUpTest, .followUpTest),
                     (.contactCase, .contactCase),
                     (.thankYou, .thankYou),
                     (.bookATest, .bookATest),
                     (.warnAndBookATest, .warnAndBookATest):
                    return true
                case (_, .keySharing),
                     (_, .followUpTest),
                     (_, .contactCase),
                     (_, .thankYou),
                     (_, .bookATest),
                     (_, .warnAndBookATest),
                     (.warnAndBookATest, _),
                     (.bookATest, _),
                     (.thankYou(_), _),
                     (.contactCase(_), _),
                     (.followUpTest, _),
                     (.keySharing(_, _), _):
                    return false
                }
            })
            .eraseToAnyPublisher()
    }
}
