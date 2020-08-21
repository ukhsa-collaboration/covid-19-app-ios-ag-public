//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Interface
import UIKit
import UserNotifications

extension CoordinatedAppController {
    
    func makeContent(for state: ApplicationState) -> UIViewController {
        switch state {
        case .starting:
            let s = UIStoryboard(name: "LaunchScreen", bundle: nil)
            return s.instantiateInitialViewController()!
            
        case .appUnavailable(let reason):
            switch reason {
            case .iOSTooOld(let descriptions):
                let vc = AppAvailabilityErrorViewController(viewModel: .init(errorType: .iOSTooOld, descriptions: descriptions))
                return UINavigationController(rootViewController: vc)
            case .appTooOld(let updateAvailable, let descriptions):
                let vc = AppAvailabilityErrorViewController(viewModel: .init(errorType: .appTooOld(updateAvailable: updateAvailable), descriptions: descriptions))
                return UINavigationController(rootViewController: vc)
            }
        case .pilotActivationRequired(let submit):
            return PilotActivationViewController {
                submit($0).regulate(as: .modelChange)
            }
            
        case .failedToStart:
            let vc = UnrecoverableErrorViewController()
            return UINavigationController(rootViewController: vc)
        case .authorizationOnboarding(requestPermissions: let requestPermissions, openURL: let openURL):
            let interactor = OnboardingInteractor(
                _requestPermissions: requestPermissions,
                _openURL: openURL
            )
            return OnboardingFlowViewController(interactor: interactor)
            
        case .postcodeOnboarding(savePostcode: let savePostcode):
            return EnterPostcodeViewController { postcode in
                Result { try savePostcode(postcode) }
            }
        case .canNotRunExposureNotification(let reason):
            var vc: UIViewController
            switch reason {
            case let .authorizationDenied(openSettings):
                let interactor = AuthorizationDeniedInteractor(_openSettings: openSettings)
                vc = AuthorizationDeniedViewController(interacting: interactor)
            case .bluetoothDisabled:
                vc = BluetoothDisabledViewController()
            }
            return UINavigationController(rootViewController: vc)
        case .runningExposureNotification(let context):
            return viewControllerForRunningApp(with: context)
        }
    }
    
    private func viewControllerForRunningApp(with context: RunningAppContext) -> UIViewController {
        WrappingViewController {
            AcknowledgementNeededState.makeAcknowledgementState(context: context)
                .regulate(as: .modelChange)
                .map { [weak self] state in
                    switch state {
                    case .notNeeded:
                        return self?.viewControllerForRunningAppIgnoringAcknowledgement(with: context)
                            ?? UIViewController()
                    case .positiveTestResultAckNeeded(let interactor, let isolationEndDate):
                        return SendKeysLoadingFlowViewController(interactor: interactor, endOfIsolation: isolationEndDate)
                    case .positiveTestResultNoIsolationAckNeeded(let interactor):
                        return SendKeysLoadingFlowViewController(interactor: interactor, endOfIsolation: nil)
                    case .negativeTestResultAckNeeded(let interactor, let isolationEndDate):
                        return NegativeTestResultWithIsolationViewController(interactor: interactor, isolationEndDate: isolationEndDate)
                    case .negativeTestResultNoIsolationAckNeeded(let interactor):
                        return NegativeTestResultViewController(interactor: interactor)
                    case .isolationEndAckNeeded(let interactor, let isolationEndDate, let showAdvisory):
                        return EndOfIsolationViewController(
                            interactor: interactor,
                            isolationEndDate: isolationEndDate,
                            showAdvisory: showAdvisory
                        )
                    case .isolationStartAckNeeded(let interactor, let isolationEndDate):
                        return ExposureAcknowledgementViewController(
                            interactor: interactor,
                            isolationEndDate: isolationEndDate
                        )
                    case .riskyVenueNeeded(let interactor, let venueName, let checkInDate):
                        return RiskyVenueInformationViewController(
                            interactor: interactor,
                            venueName: venueName,
                            checkInDate: checkInDate
                        )
                    }
                }
        }
    }
    
    private func viewControllerForRunningAppIgnoringAcknowledgement(with context: RunningAppContext) -> UIViewController {
        let interactor = HomeFlowViewControllerInteractor(context: context, pasteboardCopier: pasteboardCopier)
        
        let postcodeViewModel: RiskLevelBanner.ViewModel?
        
        if let postcodeStore = context.postcodeStore {
            postcodeViewModel = RiskLevelBanner.ViewModel(
                postcode: postcodeStore.load() ?? "",
                riskLevel: postcodeStore.$riskLevel.map {
                    switch $0 {
                    case nil: return nil
                    case .low: return .low
                    case .medium: return .medium
                    case .high: return .high
                    }
                }.property(initialValue: nil)
            )
        } else {
            postcodeViewModel = nil
        }
        
        let isolationViewModel = RiskLevelIndicator.ViewModel(
            isolationState: context.isolationState
                .publisher
                .mapToInterface(with: .default)
                .property(initialValue: .notIsolating),
            paused: context.exposureNotificationStateController.isEnabledPublisher.map { !$0 }.property(initialValue: false)
        )
        
        let showOrderTestButton = context.isolationState.publisher.map { state in
            switch state {
            case .isolate(let isolation):
                return isolation.canBookTest
            default:
                return false
            }
        }
        .property(initialValue: false)
        
        let shouldShowSelfDiagnosis = context.isolationState.publisher.map { state in
            if context.selfDiagnosisManager == nil { return false }
            if case .isolate(let isolation) = state { return isolation.canFillQuestionnaire }
            return true
        }
        .property(initialValue: false)
        
        return HomeFlowViewController(
            interactor: interactor,
            postcodeViewModel: postcodeViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: context.exposureNotificationStateController.isEnabledPublisher,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis
        )
    }
    
}

private struct OnboardingInteractor: OnboardingFlowViewController.Interacting {
    
    var _requestPermissions: () -> Void
    let _openURL: (URL) -> Void
    
    func requestPermissions() {
        _requestPermissions()
    }
    
    func didTapPrivacyNotice() {
        _openURL(ExternalLink.privacy.url)
    }
    
    func didTapTermsOfUse() {
        _openURL(ExternalLink.ourPolicies.url)
    }
}

private struct AuthorizationDeniedInteractor: AuthorizationDeniedViewController.Interacting {
    
    var _openSettings: () -> Void
    
    func didTapSettings() {
        _openSettings()
    }
}
