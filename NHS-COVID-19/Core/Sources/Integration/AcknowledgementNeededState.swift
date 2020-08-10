//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Foundation

enum AcknowledgementNeededState {
    case notNeeded
    case positiveTestResultAckNeeded(interactor: SendKeysLoadingFlowViewControllerInteractor, isolationEndDate: Date)
    case positiveTestResultNoIsolationAckNeeded(interactor: SendKeysLoadingFlowViewControllerInteractor)
    case negativeTestResultAckNeeded(interactor: NegativeTestResultWithIsolationViewControllerInteractor, isolationEndDate: Date)
    case negativeTestResultNoIsolationAckNeeded(interactor: NegativeTestResultViewControllerInteractor)
    case isolationEndAckNeeded(interactor: EndOfIsolationViewControllerInteractor, isolationEndDate: Date, showAdvisory: Bool)
    case isolationStartAckNeeded(interactor: ExposureAcknowledgementViewControllerInteractor, isolationEndDate: Date)
    case riskyVenueNeeded(interactor: RiskyVenueInformationInteractor, venueName: String, checkInDate: Date)
    
    static func makeAcknowledgementState(context: RunningAppContext, externalLinkOpener: ExternalLinkOpening) -> AnyPublisher<AcknowledgementNeededState, Never> {
        context.testResultAcknowledgementState
            .combineLatest(context.isolationAcknowledgementState, context.riskyCheckInsAcknowledgementState)
            .map { testResultAckState, isolationResultAckState, riskyVenueAckState in
                switch testResultAckState {
                case .neededForNegativeResult(let acknowledge, let isolationEndDate):
                    return .negativeTestResultAckNeeded(
                        interactor: NegativeTestResultWithIsolationViewControllerInteractor(
                            _acknowledge: acknowledge, externalLinkOpener: externalLinkOpener
                        ),
                        isolationEndDate: isolationEndDate
                    )
                case .neededForNegativeResultNoIsolation(let acknowledge):
                    return .negativeTestResultNoIsolationAckNeeded(interactor: NegativeTestResultViewControllerInteractor(
                        _acknowledge: acknowledge, externalLinkOpener: externalLinkOpener
                    ))
                case .neededForPositiveResult(let acknowledge, let isolationEndDate):
                    return .positiveTestResultAckNeeded(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(acknowledgement: acknowledge, externalLinkOpener: externalLinkOpener),
                        isolationEndDate: isolationEndDate
                    )
                case .neededForPositiveResultNoIsolation(let acknowledge):
                    return .positiveTestResultNoIsolationAckNeeded(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(acknowledgement: acknowledge, externalLinkOpener: externalLinkOpener)
                    )
                case .notNeeded:
                    switch isolationResultAckState {
                    case .neededForEnd(let isolation, let acknowledge):
                        let interactor = EndOfIsolationViewControllerInteractor(acknowledge: acknowledge, externalLinkOpener: externalLinkOpener)
                        return .isolationEndAckNeeded(interactor: interactor, isolationEndDate: isolation.endDate, showAdvisory: isolation.reason != .contactCase)
                    case .neededForStart(let isolation, let acknowledge):
                        let interactor = ExposureAcknowledgementViewControllerInteractor(externalLinkOpener: externalLinkOpener, acknowledge: acknowledge)
                        return .isolationStartAckNeeded(interactor: interactor, isolationEndDate: isolation.endDate)
                    case .notNeeded:
                        switch riskyVenueAckState {
                        case .needed(let acknowledge, let venueName, let checkInDate):
                            let interactor = RiskyVenueInformationInteractor(goHome: acknowledge)
                            return riskyVenueNeeded(interactor: interactor, venueName: venueName, checkInDate: checkInDate)
                        case .notNeeded:
                            return .notNeeded
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
}
