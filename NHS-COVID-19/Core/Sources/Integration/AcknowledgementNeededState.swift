//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation

enum AcknowledgementNeededState {
    case notNeeded
    case askForSymptomsOnsetDay(testEndDay: GregorianDay, didFinishAskForSymptomsOnsetDay: () -> Void, didConfirmSymptoms: () -> Void, setOnsetDay: (GregorianDay) -> Void)
    case neededForPositiveResultStartToIsolate(interactor: SendKeysLoadingFlowViewControllerInteractor, isolationEndDate: Date, keySubmissionSupported: Bool, requiresConfirmatoryTest: Bool)
    case neededForPositiveResultContinueToIsolate(interactor: SendKeysLoadingFlowViewControllerInteractor, isolationEndDate: Date, keySubmissionSupported: Bool, requiresConfirmatoryTest: Bool)
    case neededForPositiveResultNotIsolating(interactor: SendKeysLoadingFlowViewControllerInteractor, keySubmissionSupported: Bool)
    case neededForNegativeResultContinueToIsolate(interactor: NegativeTestResultWithIsolationViewControllerInteractor, isolationEndDate: Date)
    case neededForNegativeAfterPositiveResultContinueToIsolate(interactor: NegativeTestResultWithIsolationViewControllerInteractor, isolationEndDate: Date)
    case neededForNegativeResultNotIsolating(interactor: NegativeTestResultNoIsolationViewControllerInteractor)
    case neededForEndOfIsolation(interactor: EndOfIsolationViewControllerInteractor, isolationEndDate: Date, isIndexCase: Bool)
    case neededForStartOfIsolationExposureDetection(interactor: ExposureAcknowledgementViewControllerInteractor, isolationEndDate: Date, showDailyContactTesting: Bool)
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
                case .neededForPositiveResultStartToIsolate(let acknowledge, let isolationEndDate, let keySubmissionSupported, let requiresConfirmatoryTest):
                    return .neededForPositiveResultStartToIsolate(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(
                            acknowledgement: acknowledge,
                            openURL: context.openURL
                        ),
                        isolationEndDate: isolationEndDate,
                        keySubmissionSupported: keySubmissionSupported,
                        requiresConfirmatoryTest: requiresConfirmatoryTest
                    )
                case .neededForPositiveResultContinueToIsolate(let acknowledge, let isolationEndDate, let keySubmissionSupported, let requiresConfirmatoryTest):
                    return .neededForPositiveResultContinueToIsolate(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(
                            acknowledgement: acknowledge,
                            openURL: context.openURL
                        ),
                        isolationEndDate: isolationEndDate,
                        keySubmissionSupported: keySubmissionSupported,
                        requiresConfirmatoryTest: requiresConfirmatoryTest
                    )
                case .neededForPositiveResultNotIsolating(let acknowledge, let keySubmissionSupported):
                    return .neededForPositiveResultNotIsolating(
                        interactor: SendKeysLoadingFlowViewControllerInteractor(
                            acknowledgement: acknowledge,
                            openURL: context.openURL
                        ),
                        keySubmissionSupported: keySubmissionSupported
                    )
                case .notNeeded:
                    switch isolationResultAckState {
                    case .neededForEnd(let isolation, let acknowledge):
                        let interactor = EndOfIsolationViewControllerInteractor(acknowledge: acknowledge, openURL: context.openURL)
                        return .neededForEndOfIsolation(interactor: interactor, isolationEndDate: isolation.endDate, isIndexCase: isolation.isIndexCase)
                    case .neededForStart(let isolation, let acknowledge):
                        let interactor = ExposureAcknowledgementViewControllerInteractor(openURL: context.openURL, acknowledge: acknowledge)
                        return .neededForStartOfIsolationExposureDetection(interactor: interactor, isolationEndDate: isolation.endDate, showDailyContactTesting: context.shouldShowDailyContactTestingInformFeature())
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
                case .askForSymptomsOnsetDay(let testEndDay, let didFinishAskForSymptomsOnsetDay, let didConfirmSymptoms, let setOnsetDay):
                    return .askForSymptomsOnsetDay(testEndDay: testEndDay, didFinishAskForSymptomsOnsetDay: didFinishAskForSymptomsOnsetDay, didConfirmSymptoms: didConfirmSymptoms, setOnsetDay: setOnsetDay)
                }
            }
            .eraseToAnyPublisher()
    }
    
}
