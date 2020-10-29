//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Foundation

enum AcknowledgementNeededState {
    case notNeeded
    case neededForPositiveResultStartToIsolate(interactor: SendKeysLoadingFlowViewControllerInteractor, isolationEndDate: Date)
    case neededForPositiveResultContinueToIsolate(interactor: SendKeysLoadingFlowViewControllerInteractor, isolationEndDate: Date)
    case neededForPositiveResultNotIsolating(interactor: SendKeysLoadingFlowViewControllerInteractor)
    case neededForNegativeResultContinueToIsolate(interactor: NegativeTestResultWithIsolationViewControllerInteractor, isolationEndDate: Date)
    case neededForNegativeAfterPositiveResultContinueToIsolate(interactor: NegativeTestResultWithIsolationViewControllerInteractor, isolationEndDate: Date)
    case neededForNegativeResultNotIsolating(interactor: NegativeTestResultNoIsolationViewControllerInteractor)
    case neededForEndOfIsolation(interactor: EndOfIsolationViewControllerInteractor, isolationEndDate: Date, showAdvisory: Bool)
    case neededForStartOfIsolationExposureDetection(interactor: ExposureAcknowledgementViewControllerInteractor, isolationEndDate: Date)
    case neededForStartOfIsolationRiskyVenue(interactor: ExposureAcknowledgementViewControllerInteractor, isolationEndDate: Date)
    case neededForRiskyVenue(interactor: RiskyVenueInformationInteractor, venueName: String, checkInDate: Date)
    case neededForVoidResultContinueToIsolate(interactor: VoidTestResultFlowInteracting, isolationEndDate: Date)
    case neededForVoidResultNotIsolating(interactor: VoidTestResultFlowInteracting)
    
    static func makeAcknowledgementState(context: RunningAppContext) -> AnyPublisher<AcknowledgementNeededState, Never> {
        context.testResultAcknowledgementState
            .combineLatest(context.isolationAcknowledgementState, context.riskyCheckInsAcknowledgementState)
            .map { testResultAckState, isolationResultAckState, riskyVenueAckState in
                switch testResultAckState {
                case .neededForNegativeResultContinueToIsolate(let acknowledge, let isolationEndDate):
                    return .neededForNegativeResultContinueToIsolate(
                        interactor: NegativeTestResultWithIsolationViewControllerInteractor(
                            _acknowledge: acknowledge, openURL: context.openURL
                        ),
                        isolationEndDate: isolationEndDate
                    )
                case .neededForNegativeResultNotIsolating(let acknowledge):
                    return .neededForNegativeResultNotIsolating(interactor: NegativeTestResultNoIsolationViewControllerInteractor(
                        _acknowledge: acknowledge, openURL: context.openURL
                    ))
                case .neededForNegativeAfterPositiveResultContinueToIsolate(acknowledge: let acknowledge, isolationEndDate: let isolationEndDate):
                    return .neededForNegativeAfterPositiveResultContinueToIsolate(
                        interactor: NegativeTestResultWithIsolationViewControllerInteractor(
                            _acknowledge: acknowledge, openURL: context.openURL
                        ),
                        isolationEndDate: isolationEndDate
                    )
                case .neededForPositiveResultStartToIsolate(let acknowledge, let isolationEndDate):
                    return .neededForPositiveResultStartToIsolate(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(acknowledgement: acknowledge, openURL: context.openURL),
                        isolationEndDate: isolationEndDate
                    )
                case .neededForPositiveResultContinueToIsolate(let acknowledge, let isolationEndDate):
                    return .neededForPositiveResultContinueToIsolate(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(acknowledgement: acknowledge, openURL: context.openURL),
                        isolationEndDate: isolationEndDate
                    )
                case .neededForPositiveResultNotIsolating(let acknowledge):
                    return .neededForPositiveResultNotIsolating(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(acknowledgement: acknowledge, openURL: context.openURL)
                    )
                case .notNeeded:
                    switch isolationResultAckState {
                    case .neededForEnd(let isolation, let acknowledge):
                        let interactor = EndOfIsolationViewControllerInteractor(acknowledge: acknowledge, openURL: context.openURL)
                        return .neededForEndOfIsolation(interactor: interactor, isolationEndDate: isolation.endDate, showAdvisory: !isolation.isContactCaseOnly)
                    case .neededForStart(let isolation, let acknowledge):
                        let interactor = ExposureAcknowledgementViewControllerInteractor(openURL: context.openURL, acknowledge: acknowledge)
                        if isolation.reason == .contactCase(.exposureDetection) {
                            return .neededForStartOfIsolationExposureDetection(interactor: interactor, isolationEndDate: isolation.endDate)
                        } else {
                            return .neededForStartOfIsolationRiskyVenue(interactor: interactor, isolationEndDate: isolation.endDate)
                        }
                        
                    case .notNeeded:
                        switch riskyVenueAckState {
                        case .needed(let acknowledge, let venueName, let checkInDate):
                            let interactor = RiskyVenueInformationInteractor(goHome: acknowledge)
                            return neededForRiskyVenue(interactor: interactor, venueName: venueName, checkInDate: checkInDate)
                        case .notNeeded:
                            return .notNeeded
                        }
                    }
                    
                case .neededForVoidResultContinueToIsolate(acknowledge: let acknowledge, isolationEndDate: let isolationEndDate):
                    
                    let interactor = VoidTestResultFlowInteractor(
                        acknowledge: acknowledge
                    )
                    return .neededForVoidResultContinueToIsolate(interactor: interactor, isolationEndDate: isolationEndDate)
                case .neededForVoidResultNotIsolating(acknowledge: let acknowledge):
                    let interactor = VoidTestResultFlowInteractor(
                        acknowledge: acknowledge
                    )
                    return .neededForVoidResultNotIsolating(interactor: interactor)
                }
            }
            .eraseToAnyPublisher()
    }
    
}
