//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation

enum AcknowledgementNeededState {
    case askForSymptomsOnsetDay(testEndDay: GregorianDay, didFinishAskForSymptomsOnsetDay: () -> Void, didConfirmSymptoms: () -> Void, setOnsetDay: (GregorianDay) -> Void)
    case neededForPositiveResultStartToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForPositiveResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date, requiresConfirmatoryTest: Bool)
    case neededForPositiveResultNotIsolating(acknowledge: () -> Void)
    case neededForNegativeResultContinueToIsolate(interactor: NegativeTestResultWithIsolationViewControllerInteractor, isolationEndDate: Date)
    case neededForNegativeAfterPositiveResultContinueToIsolate(interactor: NegativeTestResultWithIsolationViewControllerInteractor, isolationEndDate: Date)
    case neededForNegativeResultNotIsolating(interactor: NegativeTestResultNoIsolationViewControllerInteractor)
    case neededForEndOfIsolation(interactor: EndOfIsolationViewControllerInteractor, isolationEndDate: Date, isIndexCase: Bool)
    case neededForStartOfIsolationExposureDetection(acknowledge: (Bool) -> Void, vaccineThresholdDate: Date, isolationEndDate: DomainProperty<Date>, isIndexCase: Bool)
    case neededForRiskyVenue(interactor: RiskyVenueInformationInteractor, venueName: String, checkInDate: Date)
    case neededForRiskyVenueWarnAndBookATest(acknowledge: () -> Void, venueName: String, checkInDate: Date)
    case neededForVoidResultContinueToIsolate(interactor: VoidTestResultFlowInteracting, isolationEndDate: Date)
    case neededForVoidResultNotIsolating(interactor: VoidTestResultFlowInteracting)
    case neededForPlodResult(interactor: PlodTestResultInteractor)
    case neededForUnknownResult(interactor: UnknownTestResultInteractor)
    
    static func makeAcknowledgementState(context: RunningAppContext) -> AnyPublisher<AcknowledgementNeededState?, Never> {
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
                        acknowledge: acknowledge,
                        isolationEndDate: isolationEndDate
                    )
                case .neededForPositiveResultContinueToIsolate(let acknowledge, let isolationEndDate, let requiresConfirmatoryTest):
                    return .neededForPositiveResultContinueToIsolate(
                        acknowledge: acknowledge,
                        isolationEndDate: isolationEndDate,
                        requiresConfirmatoryTest: requiresConfirmatoryTest
                    )
                case .neededForPositiveResultNotIsolating(let acknowledge):
                    return .neededForPositiveResultNotIsolating(
                        acknowledge: acknowledge
                    )
                case .notNeeded:
                    switch isolationResultAckState {
                    case .neededForEnd(let isolation, let acknowledge):
                        let interactor = EndOfIsolationViewControllerInteractor(acknowledge: acknowledge, openURL: context.openURL)
                        return .neededForEndOfIsolation(interactor: interactor, isolationEndDate: isolation.endDate, isIndexCase: isolation.isIndexCase)
                    case .neededForStartContactIsolation(let isolation, let acknowledge):
                        guard let vaccineThresholdDate = isolation.vaccineThresholdDate else {
                            return nil
                        }
                        
                        return .neededForStartOfIsolationExposureDetection(
                            acknowledge: acknowledge,
                            vaccineThresholdDate: vaccineThresholdDate,
                            isolationEndDate: context.isolationState.map {
                                if case .isolate(let currentIsolation) = $0 {
                                    return currentIsolation.endDate
                                } else {
                                    return isolation.endDate
                                }
                            },
                            isIndexCase: isolation.isIndexCase
                        )
                    case .notNeeded:
                        switch riskyVenueAckState {
                        case .needed(let acknowledge, let venueName, let checkInDate, let resolution):
                            switch resolution {
                            case .warnAndInform:
                                let interactor = RiskyVenueInformationInteractor(goHomeTapped: acknowledge)
                                return neededForRiskyVenue(interactor: interactor, venueName: venueName, checkInDate: checkInDate)
                            case .warnAndBookATest:
                                return neededForRiskyVenueWarnAndBookATest(acknowledge: acknowledge, venueName: venueName, checkInDate: checkInDate)
                            }
                        case .notNeeded:
                            return nil
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
                    
                case .neededForPlodResult(acknowledge: let acknowledge):
                    let interactor = PlodTestResultInteractor(
                        acknowledge: acknowledge
                    )
                    return .neededForPlodResult(interactor: interactor)
                    
                case .neededForUnknownResult(acknowledge: let acknowledge, openAppStore: let openAppStore):
                    let interactor = UnknownTestResultInteractor(
                        acknowledge: acknowledge,
                        openAppStore: openAppStore
                    )
                    return .neededForUnknownResult(interactor: interactor)
                }
            }
            .eraseToAnyPublisher()
    }
    
}
