//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Interface
import Localization
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
            
        case .onboarding(let complete, let openURL):
            let interactor = OnboardingInteractor(
                _complete: complete,
                _openURL: openURL
            )
            return OnboardingFlowViewController(interactor: interactor)
            
        case .authorizationRequired(let requestPermissions, let country):
            return PermissionsViewController(country: country.interfaceProperty, submit: requestPermissions)
            
        case .postcodeRequired(let savePostcode):
            return EnterPostcodeViewController { postcode in
                savePostcode(postcode).mapError(DisplayableError.init)
            }
        case .canNotRunExposureNotification(let reason, let country):
            var vc: UIViewController
            switch reason {
            case let .authorizationDenied(openSettings):
                let interactor = AuthorizationDeniedInteractor(_openSettings: openSettings)
                vc = AuthorizationDeniedViewController(interacting: interactor, country: country)
            case .bluetoothDisabled:
                vc = BluetoothDisabledViewController(country: country)
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
                    case .neededForPositiveResultStartToIsolate(let interactor, let isolationEndDate):
                        return SendKeysLoadingFlowViewController(interactor: interactor) { completion in
                            let interactor = PositiveTestResultWithIsolationInteractor(didTapOnlineServicesLink: interactor.didTapOnlineServicesLink, didTapPrimaryButton: completion)
                            return NonNegativeTestResultWithIsolationViewController(interactor: interactor, isolationEndDate: isolationEndDate, testResultType: .positive(.start))
                        }
                    case .neededForPositiveResultContinueToIsolate(let interactor, let isolationEndDate):
                        return SendKeysLoadingFlowViewController(interactor: interactor) { completion in
                            let interactor = PositiveTestResultWithIsolationInteractor(didTapOnlineServicesLink: interactor.didTapOnlineServicesLink, didTapPrimaryButton: completion)
                            return NonNegativeTestResultWithIsolationViewController(interactor: interactor, isolationEndDate: isolationEndDate, testResultType: .positive(.continue))
                        }
                    case .neededForPositiveResultNotIsolating(let interactor):
                        return SendKeysLoadingFlowViewController(interactor: interactor) { completion in
                            let interactor = PositiveTestResultNoIsolationInteractor(didTapOnlineServicesLink: interactor.didTapOnlineServicesLink, didTapPrimaryButton: completion)
                            return NonNegativeTestResultNoIsolationViewController(interactor: interactor)
                        }
                    case .neededForNegativeResultContinueToIsolate(let interactor, let isolationEndDate):
                        return NegativeTestResultWithIsolationViewController(interactor: interactor, viewModel: .init(isolationEndDate: isolationEndDate, testResultType: .firstResult))
                    case .neededForNegativeResultNotIsolating(let interactor):
                        return NegativeTestResultNoIsolationViewController(interactor: interactor)
                    case .neededForNegativeAfterPositiveResultContinueToIsolate(interactor: let interactor, isolationEndDate: let isolationEndDate):
                        return NegativeTestResultWithIsolationViewController(interactor: interactor, viewModel: .init(isolationEndDate: isolationEndDate, testResultType: .afterPositive))
                    case .neededForEndOfIsolation(let interactor, let isolationEndDate, let showAdvisory):
                        return EndOfIsolationViewController(
                            interactor: interactor,
                            isolationEndDate: isolationEndDate,
                            showAdvisory: showAdvisory,
                            currentDateProvider: context.currentDateProvider
                        )
                    case .neededForStartOfIsolation(let interactor, let isolationEndDate):
                        return ExposureAcknowledgementViewController(
                            interactor: interactor,
                            isolationEndDate: isolationEndDate
                        )
                    case .neededForRiskyVenue(let interactor, let venueName, let checkInDate):
                        return RiskyVenueInformationViewController(
                            interactor: interactor,
                            viewModel: .init(venueName: venueName, checkInDate: checkInDate)
                        )
                    case .neededForVoidResultContinueToIsolate(let interactor, let isolationEndDate):
                        
                        let navigationVC = UINavigationController()
                        
                        let virologyInteractor = VirologyTestingFlowInteractor(
                            virologyTestOrderInfoProvider: context.virologyTestingManager,
                            openURL: context.openURL,
                            acknowledge: interactor.acknowledge
                        )
                        
                        let bookATestInfoInteractor = BookATestInfoViewControllerInteractor(
                            didTapBookATest: {
                                let virologyFlowVC = VirologyTestingFlowViewController(virologyInteractor)
                                navigationVC.present(virologyFlowVC, animated: true)
                            },
                            openURL: context.openURL
                        )
                        
                        let bookATestInfoVC = BookATestInfoViewController(interactor: bookATestInfoInteractor, shouldHaveCancelButton: false)
                        
                        let nonNegativeInteractor = VoidTestResultWithIsolationInteractor(
                            didTapPrimaryButton: {
                                navigationVC.viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
                                navigationVC.pushViewController(bookATestInfoVC, animated: true)
                            },
                            openURL: context.openURL,
                            didTapCancel: interactor.acknowledge
                        )
                        
                        let nonNegativeVC = NonNegativeTestResultWithIsolationViewController(interactor: nonNegativeInteractor, isolationEndDate: isolationEndDate, testResultType: .void)
                        
                        navigationVC.viewControllers = [nonNegativeVC]
                        return navigationVC
                    case .neededForVoidResultNotIsolating(let interactor):
                        let navigationVC = UINavigationController()
                        
                        let virologyInteractor = VirologyTestingFlowInteractor(
                            virologyTestOrderInfoProvider: context.virologyTestingManager,
                            openURL: context.openURL,
                            acknowledge: interactor.acknowledge
                        )
                        
                        let bookATestInfoInteractor = BookATestInfoViewControllerInteractor(
                            didTapBookATest: {
                                let virologyFlowVC = VirologyTestingFlowViewController(virologyInteractor)
                                navigationVC.present(virologyFlowVC, animated: true)
                            },
                            openURL: context.openURL
                        )
                        
                        let bookATestInfoVC = BookATestInfoViewController(interactor: bookATestInfoInteractor, shouldHaveCancelButton: false)
                        
                        let nonNegativeInteractor = VoidTestResultNoIsolationInteractor(
                            didTapCancel: interactor.acknowledge,
                            bookATest: {
                                navigationVC.viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
                                navigationVC.pushViewController(bookATestInfoVC, animated: true)
                            },
                            openURL: context.openURL
                        )
                        
                        let nonNegativeVC = NonNegativeTestResultNoIsolationViewController(interactor: nonNegativeInteractor, testResultType: .void)
                        
                        navigationVC.viewControllers = [nonNegativeVC]
                        return navigationVC
                    }
                }
        }
    }
    
    private func viewControllerForRunningAppIgnoringAcknowledgement(with context: RunningAppContext) -> UIViewController {
        let interactor = HomeFlowViewControllerInteractor(
            context: context,
            pasteboardCopier: pasteboardCopier,
            currentDateProvider: context.currentDateProvider
        )
        
        let riskLevelBannerViewModel = context.postcodeInfo
            .map { postcodeInfo -> AnyPublisher<RiskLevelBanner.ViewModel?, Never> in
                guard let postcodeInfo = postcodeInfo else { return Just(nil).eraseToAnyPublisher() }
                return postcodeInfo.risk
                    .map { riskLevel -> RiskLevelBanner.ViewModel? in
                        guard let riskLevel = riskLevel else { return nil }
                        return RiskLevelBanner.ViewModel(postcode: postcodeInfo.postcode, risk: riskLevel)
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .property(initialValue: nil)
        
        let isolationViewModel = RiskLevelIndicator.ViewModel(
            isolationState: context.isolationState
                .mapToInterface(with: .default)
                .property(initialValue: .notIsolating),
            paused: context.exposureNotificationStateController.isEnabledPublisher.map { !$0 }.property(initialValue: false)
        )
        
        let showOrderTestButton = context.isolationState.map { state in
            switch state {
            case .isolate(let isolation):
                return isolation.canBookTest
            default:
                return false
            }
        }
        .property(initialValue: false)
        
        let shouldShowSelfDiagnosis = context.isolationState.map { state in
            if context.selfDiagnosisManager == nil { return false }
            if case .isolate(let isolation) = state { return isolation.canFillQuestionnaire }
            return true
        }
        .property(initialValue: false)
        
        let userNotificationEnabled = context.exposureNotificationReminder.isNotificationAuthorized.property(initialValue: false)
        
        let country = context.country.property(initialValue: context.country.currentValue)
        
        return HomeFlowViewController(
            interactor: interactor,
            riskLevelBannerViewModel: riskLevelBannerViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: context.exposureNotificationStateController.isEnabledPublisher,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            userNotificationsEnabled: userNotificationEnabled,
            country: country
        )
    }
    
}

private struct OnboardingInteractor: OnboardingFlowViewController.Interacting {
    
    var _complete: () -> Void
    let _openURL: (URL) -> Void
    
    func complete() {
        _complete()
    }
    
    func didTapPrivacyNotice() {
        _openURL(ExternalLink.privacy.url)
    }
    
    func didTapTermsOfUse() {
        _openURL(ExternalLink.ourPolicies.url)
    }
    
    func didTapAgree() {
        _complete()
    }
}

private struct AuthorizationDeniedInteractor: AuthorizationDeniedViewController.Interacting {
    
    var _openSettings: () -> Void
    
    func didTapSettings() {
        _openSettings()
    }
}
