//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Interface
import Localization
import UIKit

extension CoordinatedAppController {
    
    func makeContent(
        for state: ApplicationState
    ) -> UIViewController {
        switch state {
        case .starting:
            let s = UIStoryboard(name: "LaunchScreen", bundle: nil)
            return s.instantiateInitialViewController()!
            
        case .appUnavailable(let reason):
            switch reason {
            case .iOSTooOld(let descriptions):
                let vc = AppAvailabilityErrorViewController(
                    viewModel: .init(errorType: .iOSTooOld, descriptions: descriptions)
                )
                return BaseNavigationController(rootViewController: vc)
            case .appTooOld(let updateAvailable, let descriptions):
                let vc = AppAvailabilityErrorViewController(
                    viewModel: .init(errorType: .appTooOld(updateAvailable: updateAvailable), descriptions: descriptions)
                )
                return BaseNavigationController(rootViewController: vc)
            }
            
        case .failedToStart(let openURL):
            let interactor = UnrecoverableErrorViewControllerInteractor(openURL: openURL)
            let vc = UnrecoverableErrorViewController(interactor: interactor)
            return BaseNavigationController(rootViewController: vc)
            
        case .onboarding(let complete, let openURL):
            let interactor = OnboardingInteractor(
                complete: complete,
                openURL: openURL
            )
            return OnboardingFlowViewController(interactor: interactor)
            
        case .authorizationRequired(let requestPermissions, let country):
            return PermissionsViewController(
                country: country.interfaceProperty,
                submit: requestPermissions
            )
            
        case .postcodeAndLocalAuthorityRequired(let openURL, let getLocalAuthorities, let storeLocalAuthority):
            let interactor = LocalAuthorityOnboardingInteractor(
                openURL: openURL,
                getLocalAuthorities: getLocalAuthorities,
                storeLocalAuthority: storeLocalAuthority
            )
            return LocalAuthorityFlowViewController(interactor)
            
        case .localAuthorityRequired(let postcode, let localAuthorities, let openURL, let storeLocalAuthority):
            let localAuthoritiesForPostcode = Dictionary(uniqueKeysWithValues: localAuthorities.map { (UUID(), $0) })
            
            let interactor = LocalAuthorityUpdateInteractor(
                postcode: postcode,
                localAuthoritiesForPostcode: localAuthoritiesForPostcode,
                openURL: openURL,
                storeLocalAuthority: storeLocalAuthority
            )
            let viewModel = LocalAuthorityFlowViewModel(
                postcode: postcode.value,
                localAuthorities: localAuthoritiesForPostcode.map { Interface.LocalAuthority(id: $0.key, name: $0.value.name) }
            )
            return LocalAuthorityFlowViewController(interactor, viewModel: viewModel)
            
        case .canNotRunExposureNotification(let reason, let country):
            let vc: UIViewController
            switch reason {
            case let .authorizationDenied(openSettings):
                let interactor = AuthorizationDeniedInteractor(openSettings: openSettings)
                vc = AuthorizationDeniedViewController(
                    interacting: interactor,
                    country: country
                )
            case .bluetoothDisabled:
                vc = BluetoothDisabledViewController(country: country)
            }
            return BaseNavigationController(rootViewController: vc)
            
        case .policyAcceptanceRequired(let saveCurrentVersion, let openURL):
            let interactor = PolicyUpdateInteractor(
                saveCurrentVersion: saveCurrentVersion,
                openURL: openURL
            )
            return PolicyUpdateViewController(interactor: interactor)
            
        case .runningExposureNotification(let context):
            return viewControllerForRunningApp(with: context)
            
        case .recommendedUpdate(let reason):
            switch reason {
            case .newRecommendedAppUpdate(let title, let descriptions, let dismissAction):
                return AppAvailabilityErrorViewController(
                    viewModel: .init(
                        errorType: .recommendingAppUpdate(title: title),
                        descriptions: descriptions,
                        secondaryBtnAction: dismissAction
                    )
                )
            case .newRecommendedOSupdate(let title, let descriptions, let dismissAction):
                return AppAvailabilityErrorViewController(
                    viewModel: .init(
                        errorType: .recommendingOSUpdate(title: title),
                        descriptions: descriptions,
                        secondaryBtnAction: dismissAction
                    )
                )
            }
        }
    }
    
    private func createBookFollowUpTestFlow(
        acknowledge: @escaping () -> Void,
        context: RunningAppContext,
        isolation: NonNegativeTestResultWithIsolationViewController.TestResultType.Isolation,
        isolationEndDate: Date
    ) -> UIViewController {
        let navigationVC = BaseNavigationController()
        
        let positiveTestInteractor = PositiveTestResultWithIsolationInteractor(
            openURL: context.openURL,
            didTapPrimaryButton: { [showBookATest] in
                showBookATest.value = true
                acknowledge()
            },
            didTapCancel: acknowledge
        )
        
        let nonNegativeVC = NonNegativeTestResultWithIsolationViewController(
            interactor: positiveTestInteractor,
            isolationEndDate: isolationEndDate,
            testResultType: .positive(isolation: isolation, requiresConfirmatoryTest: true)
        )
        navigationVC.viewControllers = [nonNegativeVC]
        return navigationVC
    }
    
    private func createNonNegativeTestResultWithIsolationAcknowledgement(
        acknowledge: @escaping () -> Void,
        context: RunningAppContext,
        isolation: NonNegativeTestResultWithIsolationViewController.TestResultType.Isolation,
        isolationEndDate: Date
    ) -> UIViewController {
        let positiveTestResultWithIsolationInteractor = PositiveTestResultWithIsolationInteractor(
            openURL: context.openURL,
            didTapPrimaryButton: acknowledge
        )
        return NonNegativeTestResultWithIsolationViewController(
            interactor: positiveTestResultWithIsolationInteractor,
            isolationEndDate: isolationEndDate,
            testResultType: .positive(isolation: isolation, requiresConfirmatoryTest: false)
        )
    }
    
    private func viewControllerForRunningApp(
        with context: RunningAppContext
    ) -> UIViewController {
        WrappingViewController {
            AcknowledgementNeededState.makeAcknowledgementState(context: context)
                .regulate(as: .modelChange)
                .map { [weak self] ackState in
                    
                    guard let self = self else { return UIViewController() }
                    
                    if let ackState = ackState {
                        return self.acknowledgementViewController(
                            for: ackState,
                            context: context
                        )
                    } else {
                        return self.postAcknowledgementViewController(
                            with: context
                        )
                    }
                }
        }
    }
    
    private func acknowledgementViewController(
        for state: AcknowledgementNeededState,
        context: RunningAppContext
    ) -> UIViewController {
        switch state {
            
        case .neededForPositiveResultStartToIsolate(let acknowledge, let isolationEndDate, let requiresConfirmatoryTest):
            if requiresConfirmatoryTest {
                return createBookFollowUpTestFlow(
                    acknowledge: acknowledge,
                    context: context,
                    isolation: .start,
                    isolationEndDate: isolationEndDate
                )
            } else {
                return createNonNegativeTestResultWithIsolationAcknowledgement(
                    acknowledge: acknowledge,
                    context: context,
                    isolation: .start,
                    isolationEndDate: isolationEndDate
                )
            }
            
        case .neededForPositiveResultContinueToIsolate(let acknowledge, let isolationEndDate, let requiresConfirmatoryTest):
            if case .isolate(let isolation) = context.isolationState.currentValue,
                isolation.hasConfirmedPositiveTestResult, requiresConfirmatoryTest {
                let positiveTestResultWithIsolationInteractor = PositiveTestResultWithIsolationInteractor(
                    openURL: context.openURL,
                    didTapPrimaryButton: acknowledge
                )
                return NonNegativeTestResultWithIsolationViewController(
                    interactor: positiveTestResultWithIsolationInteractor,
                    isolationEndDate: isolationEndDate,
                    testResultType: .positiveButAlreadyConfirmedPositive
                )
            }
            
            if requiresConfirmatoryTest {
                return createBookFollowUpTestFlow(
                    acknowledge: acknowledge,
                    context: context,
                    isolation: .continue,
                    isolationEndDate: isolationEndDate
                )
            } else {
                return createNonNegativeTestResultWithIsolationAcknowledgement(
                    acknowledge: acknowledge,
                    context: context, isolation: .continue,
                    isolationEndDate: isolationEndDate
                )
            }
            
        case .neededForPositiveResultNotIsolating(let acknowledge):
            let interactor = PositiveTestResultNoIsolationInteractor(
                openURL: context.openURL,
                didTapPrimaryButton: acknowledge
            )
            return NonNegativeTestResultNoIsolationViewController(interactor: interactor)
            
        case .neededForNegativeResultContinueToIsolate(let interactor, let isolationEndDate):
            return NegativeTestResultWithIsolationViewController(
                interactor: interactor,
                viewModel: .init(isolationEndDate: isolationEndDate, testResultType: .firstResult)
            )
            
        case .neededForNegativeResultNotIsolating(let interactor):
            return NegativeTestResultNoIsolationViewController(interactor: interactor)
            
        case .neededForNegativeAfterPositiveResultContinueToIsolate(interactor: let interactor, isolationEndDate: let isolationEndDate):
            return NegativeTestResultWithIsolationViewController(
                interactor: interactor,
                viewModel: .init(isolationEndDate: isolationEndDate, testResultType: .afterPositive)
            )
            
        case .neededForEndOfIsolation(let interactor, let isolationEndDate, let isIndexCase):
            return EndOfIsolationViewController(
                interactor: interactor,
                isolationEndDate: isolationEndDate,
                isIndexCase: isIndexCase,
                currentDateProvider: context.currentDateProvider
            )
            
        case .neededForStartOfIsolationExposureDetection(let interactor, let isolationEndDate, let showDailyContactTesting):
            return ContactCaseAcknowledgementViewController(
                interactor: interactor,
                isolationEndDate: isolationEndDate,
                type: .exposureDetection,
                showDailyContactTesting: showDailyContactTesting
            )
            
        case .neededForRiskyVenue(let interactor, let venueName, let checkInDate):
            return RiskyVenueInformationViewController(
                interactor: interactor,
                viewModel: .init(venueName: venueName, checkInDate: checkInDate)
            )
            
        case .neededForRiskyVenueWarnAndBookATest(let acknowledge, _, _):
            
            let navigationVC = BaseNavigationController()
            
            let interactor = RiskyVenueInformationBookATestInteractor(
                bookATestTapped: {
                    let virologyInteractor = VirologyTestingFlowInteractor(
                        virologyTestOrderInfoProvider: context.virologyTestingManager,
                        openURL: context.openURL,
                        acknowledge: acknowledge
                    )
                    
                    let bookATestInfoInteractor = BookATestInfoViewControllerInteractor(
                        didTapBookATest: {
                            let virologyFlowVC = VirologyTestingFlowViewController(virologyInteractor)
                            navigationVC.present(virologyFlowVC, animated: true)
                        },
                        openURL: context.openURL
                    )
                    
                    let bookATestInfoVC = BookATestInfoViewController(
                        interactor: bookATestInfoInteractor,
                        shouldHaveCancelButton: false
                    )
                    navigationVC.pushViewController(bookATestInfoVC, animated: true)
                }, goHomeTapped: {
                    acknowledge()
                }
            )
            
            let riskyVenueInformationBookATestViewController = RiskyVenueInformationBookATestViewController(interactor: interactor)
            navigationVC.viewControllers = [riskyVenueInformationBookATestViewController]
            return navigationVC
            
        case .neededForVoidResultContinueToIsolate(let interactor, let isolationEndDate):
            
            let navigationVC = BaseNavigationController()
            
            let nonNegativeInteractor = VoidTestResultWithIsolationInteractor(
                didTapPrimaryButton: { [showBookATest] in
                    showBookATest.value = true
                    interactor.acknowledge()
                },
                openURL: context.openURL,
                didTapCancel: interactor.acknowledge
            )
            
            let nonNegativeVC = NonNegativeTestResultWithIsolationViewController(
                interactor: nonNegativeInteractor,
                isolationEndDate: isolationEndDate,
                testResultType: .void
            )
            navigationVC.viewControllers = [nonNegativeVC]
            return navigationVC
            
        case .neededForVoidResultNotIsolating(let interactor):
            let navigationVC = BaseNavigationController()
            
            let nonNegativeInteractor = VoidTestResultNoIsolationInteractor(
                didTapCancel: interactor.acknowledge,
                bookATest: { [showBookATest] in
                    showBookATest.value = true
                    interactor.acknowledge()
                },
                openURL: context.openURL
            )
            
            let nonNegativeVC = NonNegativeTestResultNoIsolationViewController(
                interactor: nonNegativeInteractor,
                testResultType: .void
            )
            navigationVC.viewControllers = [nonNegativeVC]
            return navigationVC
            
        case .askForSymptomsOnsetDay(let testEndDay, let didFinishAskForSymptomsOnsetDay, let didConfirmSymptoms, let setOnsetDay):
            return SymptomsOnsetDayFlowViewController(
                testEndDay: testEndDay,
                didFinishAskForSymptomsOnsetDay: didFinishAskForSymptomsOnsetDay,
                setOnsetDay: setOnsetDay,
                recordDidHaveSymptoms: didConfirmSymptoms
            )
        }
    }
    
    private func postAcknowledgementViewController(
        with context: RunningAppContext
    ) -> UIViewController {
        WrappingViewController { [showBookATest, showContactTracingHub] in
            Localization.configurationChangePublisher
                .map { _ in true }
                .prepend(false)
                .map { value in
                    PostAcknowledgementViewController(
                        context: context,
                        shouldShowLanguageSelectionScreen: value,
                        showBookATest: showBookATest,
                        showContactTracingHub: showContactTracingHub
                    )
                }
        }
    }
}

private struct OnboardingInteractor: OnboardingFlowViewController.Interacting {
    
    var complete: () -> Void
    let openURL: (URL) -> Void
    
    func didTapPrivacyNotice() {
        openURL(ExternalLink.privacy.url)
    }
    
    func didTapTermsOfUse() {
        openURL(ExternalLink.ourPolicies.url)
    }
    
    func didTapAgree() {
        complete()
    }
}

private struct AuthorizationDeniedInteractor: AuthorizationDeniedViewController.Interacting {
    
    var openSettings: () -> Void
    
    func didTapSettings() {
        openSettings()
    }
}

private struct PolicyUpdateInteractor: PolicyUpdateViewController.Interacting {
    var saveCurrentVersion: () -> Void
    let openURL: (URL) -> Void
    
    func didTapContinue() {
        saveCurrentVersion()
    }
    
    func didTapTermsOfUse() {
        openURL(ExternalLink.ourPolicies.url)
    }
}

class LocalAuthorityOnboardingInteractor: LocalAuthorityFlowViewController.Interacting {
    private let openURL: (URL) -> Void
    private let getLocalAuthorities: (Postcode) -> Result<Set<Domain.LocalAuthority>, PostcodeValidationError>
    private let storeLocalAuthority: (Postcode, Domain.LocalAuthority) -> Result<Void, LocalAuthorityUnsupportedCountryError>
    
    private var postcode: Postcode?
    private var localAuthoritiesForPostcode: [UUID: Domain.LocalAuthority]?
    
    init(
        openURL: @escaping (URL) -> Void,
        getLocalAuthorities: @escaping (Postcode) -> Result<Set<Domain.LocalAuthority>, PostcodeValidationError>,
        storeLocalAuthority: @escaping (Postcode, Domain.LocalAuthority) -> Result<Void, LocalAuthorityUnsupportedCountryError>
    ) {
        self.openURL = openURL
        self.getLocalAuthorities = getLocalAuthorities
        self.storeLocalAuthority = storeLocalAuthority
    }
    
    func localAuthorities(
        for postcode: String
    ) -> Result<[Interface.LocalAuthority], DisplayableError> {
        return getLocalAuthorities(Postcode(postcode))
            .map { authoritySet in
                self.postcode = Postcode(postcode)
                self.localAuthoritiesForPostcode = Dictionary(uniqueKeysWithValues: authoritySet.map { (UUID(), $0) })
                return localAuthoritiesForPostcode!.map {
                    Interface.LocalAuthority(id: $0.key, name: $0.value.name)
                }
            }
            .mapError(DisplayableError.init)
    }
    
    func confirmLocalAuthority(
        _ localAuthority: Interface.LocalAuthority?
    ) -> Result<Void, LocalAuthoritySelectionError> {
        if let localAuthority = localAuthority {
            if let postcode = self.postcode,
                let authority = localAuthoritiesForPostcode?[localAuthority.id] {
                
                return storeLocalAuthority(postcode, authority).mapError(LocalAuthoritySelectionError.init)
            } else {
                assertionFailure("This should not be possible.")
                return Result.failure(.unsupportedCountry)
            }
        } else {
            return Result.failure(.emptySelection)
        }
        
    }
    
    func didTapGovUKLink() {
        openURL(ExternalLink.visitUKgov.url)
    }
}

private struct LocalAuthorityUpdateInteractor: LocalAuthorityFlowViewController.Interacting {
    private let openURL: (URL) -> Void
    private let storeLocalAuthority: (Postcode, Domain.LocalAuthority) -> Result<Void, LocalAuthorityUnsupportedCountryError>
    private let postcode: Postcode
    private let localAuthoritiesForPostcode: [UUID: Domain.LocalAuthority]
    
    init(
        postcode: Postcode,
        localAuthoritiesForPostcode: [UUID: Domain.LocalAuthority],
        openURL: @escaping (URL) -> Void,
        storeLocalAuthority: @escaping (Postcode, Domain.LocalAuthority) -> Result<Void, LocalAuthorityUnsupportedCountryError>
    ) {
        self.postcode = postcode
        self.localAuthoritiesForPostcode = localAuthoritiesForPostcode
        self.openURL = openURL
        self.storeLocalAuthority = storeLocalAuthority
    }
    
    #warning("Find a better way to avoid implementing this function")
    func localAuthorities(
        for postcode: String
    ) -> Result<[Interface.LocalAuthority], DisplayableError> {
        assertionFailure("This should never be called.")
        return Result.success(localAuthoritiesForPostcode.map { Interface.LocalAuthority(id: $0.key, name: $0.value.name) })
    }
    
    func confirmLocalAuthority(
        _ localAuthority: Interface.LocalAuthority?
    ) -> Result<Void, LocalAuthoritySelectionError> {
        if let localAuthority = localAuthority {
            if let authority = localAuthoritiesForPostcode[localAuthority.id] {
                return storeLocalAuthority(postcode, authority).mapError(LocalAuthoritySelectionError.init)
            } else {
                preconditionFailure("Local Authority id must be in the list")
            }
        } else {
            return Result.failure(.emptySelection)
        }
        
    }
    
    func didTapGovUKLink() {
        openURL(ExternalLink.visitUKgov.url)
    }
}

extension LocalAuthoritySelectionError {
    init(_ error: LocalAuthorityUnsupportedCountryError) {
        self = .unsupportedCountry
    }
}

private struct UnrecoverableErrorViewControllerInteractor: UnrecoverableErrorViewControllerInteracting {
    
    let openURL: (URL) -> Void
    
    func faqLinkTapped() {
        openURL(ExternalLink.cantRunThisAppFAQs.url)
    }
}

private struct ThankYouInteractor: ThankYouViewController.Interacting {
    private let _action: () -> Void
    
    init(action: @escaping () -> Void) {
        _action = action
    }
    
    func action() {
        _action()
    }
}
