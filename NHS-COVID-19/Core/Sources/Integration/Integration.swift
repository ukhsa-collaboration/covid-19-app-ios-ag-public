//
// Copyright © 2022 DHSC. All rights reserved.
//

import Domain
import Interface
import Localization
import UIKit

@available(iOSApplicationExtension, unavailable)
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

        case .onboarding(
            let complete,
            let openURL,
            let isFeatureEnabled
        ):
            let interactor = OnboardingInteractor(
                complete: complete,
                openURL: openURL
            )
            return OnboardingFlowViewController(
                interactor: interactor,
                shouldShowVenueCheckIn: isFeatureEnabled(.venueCheckIn)
            )

        case .authorizationRequired(let requestPermissions, let country):
            return ContactTracingBluetoothViewController(
                interactor: ContactTracingBluetoothInteractor(submitAction: requestPermissions),
                country: country.interfaceProperty
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

    private func createNonNegativeTestResultWithIsolationAcknowledgement(
        acknowledge: @escaping () -> Void,
        context: RunningAppContext,
        isolation: NonNegativeTestResultWithIsolationViewController.TestResultType.Isolation,
        isolationEndDate: Date,
        testResultType: NonNegativeTestResultWithIsolationViewController.TestResultType
    ) -> UIViewController {
        let positiveTestResultWithIsolationInteractor = PositiveTestResultWithIsolationInteractor(
            openURL: context.openURL,
            didTapPrimaryButton: acknowledge
        )
        return NonNegativeTestResultWithIsolationViewController(
            interactor: positiveTestResultWithIsolationInteractor,
            isolationEndDate: isolationEndDate,
            testResultType: testResultType,
            currentDateProvider: context.currentDateProvider
        )
    }

    private func createAdviceForAlreadyIsolatingInEngland(
        acknowledge: @escaping () -> Void,
        context: RunningAppContext
    ) -> UIViewController {
        let interactor = AdviceForIndexCasesEnglandAlreadyIsolatingInteractor(
            openURL: context.openURL,
            didTapPrimaryButton: acknowledge
        )
        return AdviceForIndexCasesEnglandAlreadyIsolatingViewController(interactor: interactor)
    }

    private func createAdviceForIndexCaseEngland(
        acknowledge: @escaping () -> Void,
        context: RunningAppContext
    ) -> UIViewController {
        let adviceForIndexCaseInteractor = AdviceForIndexCasesEnglandInteractor(
            openURL: context.openURL,
            didTapPrimaryButton: acknowledge
        )
        return AdviceForIndexCasesEnglandViewController(interactor: adviceForIndexCaseInteractor)
    }

    private func createAdviceOrIsolationController(
        acknowledge: @escaping () -> Void,
        context: RunningAppContext,
        isolation: NonNegativeTestResultWithIsolationViewController.TestResultType.Isolation,
        isolationEndDate: Date,
        testResultType: NonNegativeTestResultWithIsolationViewController.TestResultType
    ) -> UIViewController {
        switch context.country.currentValue {
        case .england:
            switch isolation {
            case .continue:
                return createAdviceForAlreadyIsolatingInEngland(
                    acknowledge: acknowledge,
                    context: context
                )
            case .start:
                return createAdviceForIndexCaseEngland(
                    acknowledge: acknowledge,
                    context: context
                )
            }

        case .wales:
            return createNonNegativeTestResultWithIsolationAcknowledgement(
                acknowledge: acknowledge,
                context: context,
                isolation: isolation,
                isolationEndDate: isolationEndDate,
                testResultType: testResultType
            )
        }
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
        case .neededForPositiveResultStartToIsolate(let acknowledge, let isolationEndDate):
            return createAdviceOrIsolationController(
                acknowledge: acknowledge,
                context: context,
                isolation: .start,
                isolationEndDate: isolationEndDate,
                testResultType: .positive(isolation: .start, requiresConfirmatoryTest: false)
            )

        case .neededForPositiveResultContinueToIsolate(let acknowledge, let isolationEndDate, let requiresConfirmatoryTest):
            if case .isolate(let isolation) = context.isolationState.currentValue,
                isolation.hasConfirmedPositiveTestResult, requiresConfirmatoryTest {
                return createAdviceOrIsolationController(
                    acknowledge: acknowledge,
                    context: context,
                    isolation: .continue,
                    isolationEndDate: isolationEndDate,
                    testResultType: .positiveButAlreadyConfirmedPositive
                )
            }

            return createAdviceOrIsolationController(
                acknowledge: acknowledge,
                context: context,
                isolation: .continue,
                isolationEndDate: isolationEndDate,
                testResultType: .positive(isolation: .continue, requiresConfirmatoryTest: false)
            )

        case .neededForPositiveResultNotIsolating(let acknowledge):
            let interactor = PositiveTestResultNoIsolationInteractor(
                openURL: context.openURL,
                didTapPrimaryButton: acknowledge
            )
            return NonNegativeTestResultNoIsolationViewController(interactor: interactor)

        case .neededForNegativeResultContinueToIsolate(let interactor, let isolationEndDate):
            return NegativeTestResultWithIsolationViewController(
                interactor: interactor,
                viewModel: .init(isolationEndDate: isolationEndDate, testResultType: .firstResult), currentDateProvider: context.currentDateProvider
            )

        case .neededForNegativeResultNotIsolating(let interactor):
            return NegativeTestResultNoIsolationViewController(interactor: interactor)

        case .neededForNegativeAfterPositiveResultContinueToIsolate(interactor: let interactor, isolationEndDate: let isolationEndDate):
            return NegativeTestResultWithIsolationViewController(
                interactor: interactor,
                viewModel: .init(isolationEndDate: isolationEndDate, testResultType: .afterPositive), currentDateProvider: context.currentDateProvider
            )

        case .neededForEndOfIsolation(let interactor, let isolationEndDate, let isIndexCase):
            return EndOfIsolationViewController(
                interactor: interactor,
                isolationEndDate: isolationEndDate,
                isIndexCase: isIndexCase,
                currentDateProvider: context.currentDateProvider,
                currentCountry: context.country.currentValue
            )

        case .neededForStartOfIsolationExposureDetection(let acknowledge, let exposureDate, let birthThresholdDate, let vaccineThresholdDate, let secondTestAdviceDate, let isolationEndDate, let isIndexCase):

            var shouldShowOptOutFlow: Bool {
                switch context.country.currentValue {
                case .england:
                    return context.shouldShowEnglandOptOutFlow
                case .wales:
                    return context.shouldShowWalesOptOutFlow
                }
            }

            if !shouldShowOptOutFlow {
                if isIndexCase {
                    return ContactCaseExposureInfoEnglandViewController(
                        interactor: ContactCaseExposureInfoInteractor(acknowledge: { [showUIState] in
                            acknowledge(true)
                            showUIState.value = .showContactCaseResult(.continueIsolation(endDate: isolationEndDate.currentValue, secondTestAdviceDate: secondTestAdviceDate))
                        }),
                        exposureDate: exposureDate
                    )
                } else {
                    return ContactCaseImmediateAcknowledgementFlowViewController(
                        interactor: ContactCaseImmediateAcknowledgementFlowViewControllerInteractor(acknowledge: {
                            acknowledge(true)
                        }), country: context.country.currentValue,
                        openURL: context.openURL,
                        exposureDate: exposureDate
                    )
                }
            } else {
                let interactor = ContactCaseMultipleResolutionsFlowViewControllerInteractor(
                    openURL: context.openURL,
                    didDeclareVaccinationStatus: { answers in
                        let mappedAnswers = answers.mapAnswersToDomain()
                        let result = context.contactCaseOptOutQuestionnaire.getResolution(with: mappedAnswers)

                        switch result {
                        case .notFinished:
                            return .failure(ContactCaseVaccinationStatusNotEnoughAnswersError())
                        case .optedOutOfIsolation(_, let questions):
                            return .success(ContactCaseResolution(overAgeLimit: true, vaccinationStatusAnswers: answers.mapAnswersWithInterfaceQuestions(questions: questions)))
                        case .needToIsolate(let questions):
                            return .success(ContactCaseResolution(overAgeLimit: true, vaccinationStatusAnswers: answers.mapAnswersWithInterfaceQuestions(questions: questions)))
                        }
                    }, nextVaccinationStatusQuestion: { answers in
                        let mappedAnswers = answers.mapAnswersToDomain()
                        return context.contactCaseOptOutQuestionnaire.nextQuestion(with: mappedAnswers).map(ContactCaseVaccinationStatusQuestion.init)
                    },
                    didReviewQuestions: { [showUIState] overAgeLimit, vaccinationStatusAnswers in
                        if !overAgeLimit {
                            acknowledge(true)
                            if isIndexCase {
                                showUIState.value = .showContactCaseResult(.continueIsolation(endDate: isolationEndDate.currentValue, secondTestAdviceDate: secondTestAdviceDate))
                            } else {
                                showUIState.value = .showContactCaseResult(.underAgeLimit(secondTestAdviceDate: secondTestAdviceDate))
                            }
                        } else {
                            let mappedAnswers = vaccinationStatusAnswers.mapAnswersToDomain()
                            let result = context.contactCaseOptOutQuestionnaire.getResolution(with: mappedAnswers)

                            let didOptOut: Bool
                            let optOutReason: ContactCaseOptOutReason?
                            switch result {
                            case .notFinished:
                                assertionFailure("Should not be possible")
                                didOptOut = false
                                optOutReason = nil
                            case .optedOutOfIsolation(let reason, _):
                                didOptOut = true
                                optOutReason = reason
                            case .needToIsolate:
                                didOptOut = false
                                optOutReason = nil
                            }

                            acknowledge(didOptOut)
                            if isIndexCase {
                                showUIState.value = .showContactCaseResult(.continueIsolation(endDate: isolationEndDate.currentValue, secondTestAdviceDate: secondTestAdviceDate))
                            } else if didOptOut {
                                switch optOutReason {
                                case .fullyVaccinated, .none:
                                    showUIState.value = .showContactCaseResult(.fullyVaccinated(secondTestAdviceDate: secondTestAdviceDate))
                                case .medicallyExempt:
                                    showUIState.value = .showContactCaseResult(.medicallyExempt)
                                }
                            } else {
                                showUIState.value = .showContactCaseResult(
                                    .startIsolation(
                                        endDate: isolationEndDate.currentValue,
                                        exposureDate: exposureDate,
                                        secondTestAdviceDate: secondTestAdviceDate
                                    ))
                            }
                        }
                    }
                )

                return ContactCaseMultipleResolutionsFlowViewController(
                    interactor: interactor,
                    isIndexCase: isIndexCase,
                    exposureDate: exposureDate,
                    birthThresholdDate: birthThresholdDate,
                    vaccineThresholdDate: vaccineThresholdDate
                )

            }

        case .neededForRiskyVenue(let interactor, let venueName, let checkInDate):
            return RiskyVenueInformationViewController(
                interactor: interactor,
                viewModel: .init(venueName: venueName, checkInDate: checkInDate)
            )

        case .neededForRiskyVenueWarnAndBookATest(let acknowledge, _, _):

            let navigationVC = BaseNavigationController()

            let isIndexCaseIsolation: Bool = {
                if case .isolate(let isolation) = context.isolationState.currentValue {
                    return isolation.isIndexCase
                } else {
                    return false
                }
            }()

            let interactor = RiskyVenueInformationBookATestInteractor(
                bookATestTapped: { [showUIState] in
                    showUIState.send(isIndexCaseIsolation ? .showBookATest : .showWarnAndBookATest)
                    acknowledge()
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
                didTapPrimaryButton: { interactor.acknowledge() },
                openURL: context.openURL,
                didTapCancel: interactor.acknowledge
            )

            let nonNegativeVC = NonNegativeTestResultWithIsolationViewController(
                interactor: nonNegativeInteractor,
                isolationEndDate: isolationEndDate,
                testResultType: .void,
                currentDateProvider: context.currentDateProvider
            )
            navigationVC.viewControllers = [nonNegativeVC]
            return navigationVC

        case .neededForVoidResultNotIsolating(let interactor):
            let navigationVC = BaseNavigationController()

            let nonNegativeInteractor = VoidTestResultNoIsolationInteractor(
                didTapCancel: interactor.acknowledge,
                didTapPrimaryButton: { interactor.acknowledge() },
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

        case .neededForPlodResult(interactor: let interactor):
            let plodTestResultVC = PlodTestResultViewController(interactor: interactor)
            return plodTestResultVC

        case .neededForUnknownResult(interactor: let interactor):
            let unknownTestResultVC = UnknownTestResultsViewController(interactor: interactor)
            return BaseNavigationController(rootViewController: unknownTestResultVC)
        }
    }

    private func postAcknowledgementViewController(
        with context: RunningAppContext
    ) -> UIViewController {
        WrappingViewController { [showUIState, showNotificationScreen] in
            Localization.configurationChangePublisher
                .map { _ in true }
                .prepend(false)
                .map { value in
                    PostAcknowledgementViewController(
                        context: context,
                        shouldShowLanguageSelectionScreen: value,
                        showUIState: showUIState,
                        showNotificationScreen: showNotificationScreen
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

private struct ContactTracingBluetoothInteractor: ContactTracingBluetoothViewController.Interacting {
    let submitAction: () -> Void

    init(submitAction: @escaping () -> Void) {
        self.submitAction = submitAction
    }

    func didTapContinueButton() {
        submitAction()
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

private extension ContactCaseVaccinationStatusQuestion {
    init(question: ContactCaseOptOutQuestion) {
        switch question {
        case .fullyVaccinated:
            self = .fullyVaccinated
        case .lastDose:
            self = .lastDose
        case .clinicalTrial:
            self = .clinicalTrial
        case .medicallyExempt:
            self = .medicallyExempt
        }
    }
}

private extension ContactCaseVaccinationStatusAnswers {
    func mapAnswersToDomain() -> [ContactCaseOptOutQuestion: Bool] {
        var mappedAnswers: [ContactCaseOptOutQuestion: Bool] = [:]
        fullyVaccinated.map { mappedAnswers[.fullyVaccinated] = $0 }
        lastDose.map { mappedAnswers[.lastDose] = $0 }
        clinicalTrial.map { mappedAnswers[.clinicalTrial] = $0 }
        medicallyExempt.map { mappedAnswers[.medicallyExempt] = $0 }
        return mappedAnswers
    }

    func mapAnswersWithInterfaceQuestions(questions: [ContactCaseOptOutQuestion]) -> [ContactCaseVaccinationStatusQuestionAndAnswer] {
        var questionsAnswers: [ContactCaseVaccinationStatusQuestionAndAnswer] = []
        for question in questions {
            switch question {
            case .fullyVaccinated:
                if let fullyVaccinated = fullyVaccinated {
                    questionsAnswers.append(
                        ContactCaseVaccinationStatusQuestionAndAnswer(
                            question: .fullyVaccinated,
                            answer: fullyVaccinated
                        )
                    )
                }
            case .lastDose:
                if let lastDose = lastDose {
                    questionsAnswers.append(
                        ContactCaseVaccinationStatusQuestionAndAnswer(
                            question: .lastDose,
                            answer: lastDose
                        )
                    )
                }
            case .clinicalTrial:
                if let clinicalTrial = clinicalTrial {
                    questionsAnswers.append(
                        ContactCaseVaccinationStatusQuestionAndAnswer(
                            question: .clinicalTrial,
                            answer: clinicalTrial
                        )
                    )
                }

            case .medicallyExempt:
                if let medicallyExempt = medicallyExempt {
                    questionsAnswers.append(
                        ContactCaseVaccinationStatusQuestionAndAnswer(
                            question: .medicallyExempt,
                            answer: medicallyExempt
                        )
                    )
                }

            }
        }
        return questionsAnswers
    }
}

private struct ContactCaseImmediateAcknowledgementFlowViewControllerInteractor: ContactCaseImmediateAcknowledgementFlowViewController.Interacting {
    let _acknowledge: () -> Void

    init(acknowledge: @escaping () -> Void) {
        _acknowledge = acknowledge
    }

    func acknowledge() {
        _acknowledge()
    }
}

private struct ContactCaseExposureInfoInteractor: ContactCaseExposureInfoEnglandViewController.Interacting {
    private let _acknowledge: () -> Void

    init(acknowledge: @escaping () -> Void) {
        _acknowledge = acknowledge
    }

    func didTapContinue() {
        _acknowledge()
    }
}
