//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Interface
import Localization
import UIKit

struct HomeFlowViewControllerInteractor: HomeFlowViewController.Interacting {
    func save(postcode: String) -> Result<Void, DisplayableError> {
        context.savePostcode?(postcode).mapError(DisplayableError.init) ?? .success(())
    }
    
    func getCurrentLocaleConfiguration() -> InterfaceProperty<LocaleConfiguration> {
        context.currentLocaleConfiguration.interfaceProperty
    }
    
    func storeNewLanguage(_ localeConfiguration: LocaleConfiguration) {
        context.storeNewLanguage(localeConfiguration)
    }
    
    var context: RunningAppContext
    var currentDateProvider: DateProviding
    
    func makeLocalAuthorityOnboardingIteractor() -> LocalAuthorityFlowViewController.Interacting? {
        guard let getLocalAuthorities = context.getLocalAuthorities, let storeLocalAuthorities = context.storeLocalAuthorities else {
            return nil
        }
        return LocalAuthorityOnboardingIteractor(openURL: context.openURL, getLocalAuthorities: getLocalAuthorities, storeLocalAuthority: storeLocalAuthorities)
    }
    
    func makeDiagnosisViewController() -> UIViewController? {
        WrappingViewController {
            SelfDiagnosisOrderFlowState.makeState(context: context)
                .map { state in
                    switch state {
                    case .selfDiagnosis(let interactor, let isolationState):
                        return SelfDiagnosisFlowViewController(interactor, initialIsolationState: isolationState)
                    case .testOrdering(let interactor):
                        return VirologyTestingFlowViewController(interactor)
                    }
                }
        }
    }
    
    func makeCheckInViewController() -> UIViewController? {
        guard let checkInContext = context.checkInContext else { return nil }
        
        let interactor = CheckInInteractor(
            _openSettings: context.openSettings,
            _process: {
                let (venueName, removeCurrentCheckIn) = try checkInContext.checkInsStore.checkIn(with: $0, currentDate: self.context.currentDateProvider.currentDate)
                return CheckInDetail(venueName: venueName, removeCurrentCheckIn: removeCurrentCheckIn)
            }
        )
        
        let qrCodeScanner = checkInContext.qrCodeScanner
        
        let cameraPermissionStatePublisher = qrCodeScanner.cameraStateController.$authorizationState.map { state -> CameraPermissionState in
            switch state {
            case .notDetermined:
                return .notDetermined
            case .authorized:
                return .authorized
            case .denied, .restricted:
                return .denied
            }
        }.eraseToAnyPublisher()
        
        qrCodeScanner.reset()
        let scanner = QRScanner(
            state: qrCodeScanner.getState().map { state in
                switch state {
                case .starting:
                    return .starting
                case .failed:
                    return .failed
                case .requestingPermission:
                    return .requestingPermission
                case .running:
                    return .running
                case .scanning:
                    return .scanning
                case .processing:
                    return .processing
                case .stopped:
                    return .stopped
                }
            }.eraseToAnyPublisher(),
            startScanning: qrCodeScanner.startScanner,
            stopScanning: qrCodeScanner.stopScanner,
            layoutFinished: qrCodeScanner.changeOrientation
        )
        
        return CheckInFlowViewController(
            cameraPermissionState: cameraPermissionStatePublisher,
            scanner: scanner,
            interactor: interactor,
            currentDateProvider: currentDateProvider,
            goHomeCompletion: context.appReviewPresenter.presentReview
        )
    }
    
    func makeTestingInformationViewController() -> UIViewController? {
        WrappingViewController {
            BookATestFlowState.makeState(context: context)
                .map { state in
                    switch state {
                    case .bookATest(let interactor):
                        return BaseNavigationController(rootViewController: BookATestInfoViewController(interactor: interactor, shouldHaveCancelButton: true))
                    case .testOrdering(let interactor):
                        return VirologyTestingFlowViewController(interactor)
                    }
                }
        }
    }
    
    func makeFinancialSupportViewController() -> UIViewController? {
        switch context.isolationPaymentState.currentValue {
        case .disabled: return nil
        case .enabled(let apply):
            return IsolationPaymentFlowViewController(openURL: context.openURL, didTapCheckEligibility: apply, recordLaunchedIsolationPaymentsApplication: { Metrics.signpost(.launchedIsolationPaymentsApplication) })
        }
    }
    
    func makeLinkTestResultViewController() -> UIViewController? {
        
        let baseNavigationController = BaseNavigationController()
        
        let interactor = LinkTestResultInteractor(
            dailyContactTestingEarlyTerminationSupport: context.dailyContactTestingEarlyTerminationSupport(),
            showNextScreen: { terminate in
                if let dailyConfirmationVC = makeDailyConfirmationViewController(
                    parentVC: baseNavigationController,
                    with: terminate
                ) {
                    baseNavigationController.pushViewController(dailyConfirmationVC, animated: true)
                }
            },
            _submit: { testCode in
                self.context.virologyTestingManager.linkExternalTestResult(with: testCode)
                    .mapError(DisplayableError.init)
                    .eraseToAnyPublisher()
            }
            
        )
        baseNavigationController.pushViewController(LinkTestResultViewController(interactor: interactor), animated: false)
        
        return baseNavigationController
    }
    
    func makeDailyConfirmationViewController(parentVC: UIViewController, with terminate: @escaping () -> Void) -> UIViewController? {
        
        let interactor = DailyContactTestingConfirmationInteractor(
            action: {
                let alertController = makeDCTConfirmationAlert(with: terminate)
                parentVC.present(alertController, animated: true)
            }
            
        )
        
        return DailyContactTestingConfirmationViewController(interactor: interactor)
    }
    
    private func makeDCTConfirmationAlert(with action: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(
            title: localize(.daily_contact_testing_confirmation_screen_alert_title),
            message: localize(.daily_contact_testing_confirmation_screen_alert_body_description),
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: localize(.daily_contact_testing_confirmation_screen_alert_confirm_button_title), style: .default) { _ in action() }
        
        alertController.addAction(UIAlertAction(title: localize(.cancel), style: .default))
        alertController.addAction(confirmAction)
        alertController.preferredAction = confirmAction
        
        return alertController
    }
    
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        context.exposureNotificationStateController.setEnabled(enabled)
    }
    
    public func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn) {
        context.exposureNotificationReminder.scheduleUserNotification(in: reminderIn.rawValue)
    }
    
    var shouldShowCheckIn: Bool {
        context.checkInContext != nil
    }
    
    func getMyDataViewModel() -> MyDataViewController.ViewModel {
        let venueHistories = context.checkInContext?.checkInsStore.load()?.map { checkIn -> VenueHistory in
            VenueHistory(
                id: checkIn.venueId,
                organisation: checkIn.venueName,
                checkedIn: checkIn.checkedIn.date,
                checkedOut: checkIn.checkedOut.date,
                delete: {
                    self.context.deleteCheckIn(checkIn.id)
                }
            )
        } ?? []
        
        let testResultDetails: MyDataViewController.ViewModel.TestResultDetails? = context.testInfo.currentValue.map {
            
            // map from the Domain level ConfirmationStatus to the Interface level ConfirmationStatus
            let confirmationStatus: MyDataViewController.ViewModel.TestResultDetails.ConfirmationStatus = { testInfo in
                switch testInfo.confirmationStatus {
                case .pending:
                    return MyDataViewController.ViewModel.TestResultDetails.ConfirmationStatus.pending
                case .notRequired:
                    return MyDataViewController.ViewModel.TestResultDetails.ConfirmationStatus.notRequired
                case .confirmed(let confirmedOnDay):
                    return MyDataViewController.ViewModel.TestResultDetails.ConfirmationStatus.confirmed(onDay: confirmedOnDay)
                }
            }($0)
            
            return MyDataViewController.ViewModel.TestResultDetails(
                result: Interface.TestResult(domainTestResult: $0.result),
                date: $0.receivedOnDay.startDate(in: .current),
                testKitType: $0.testKitType.map(Interface.TestKitType.init(domainTestKitType:)),
                confirmationStatus: confirmationStatus
            )
        }
        
        let symptomsOnsetDate = context.symptomsOnsetAndExposureDetailsProvider.provideSymptomsOnsetDate()
        let exposureDetails = context.symptomsOnsetAndExposureDetailsProvider.provideExposureDetails()
        
        // TODO: We may want to pass this through as an interface property or similar rather than computing its instantaneous value here.
        let selfIsolationEndDate = { () -> Date? in
            switch context.isolationState.currentValue {
            case .isolate(let isolation):
                return isolation.endDate
            case .noNeedToIsolate:
                return nil
            }
        }()
        // TODO: We may want to pass this through as an interface property or similar rather than computing its instantaneous value here.
        let dailyTestingOptInDate = { () -> Date? in
            switch context.isolationState.currentValue {
            case .isolate:
                return nil
            case .noNeedToIsolate(let date):
                return date
            }
        }()
        
        return .init(
            postcode: context.postcodeInfo.map { $0?.postcode.value }.interfaceProperty,
            localAuthority: context.postcodeInfo.map { $0?.localAuthority?.name }.interfaceProperty,
            testResultDetails: testResultDetails,
            venueHistories: venueHistories,
            symptomsOnsetDate: symptomsOnsetDate,
            exposureNotificationDetails: exposureDetails.map { details in
                MyDataViewController.ViewModel.ExposureNotificationDetails(
                    encounterDate: details.encounterDate,
                    notificationDate: details.notificationDate
                )
            },
            selfIsolationEndDate: selfIsolationEndDate,
            dailyTestingOptInDate: dailyTestingOptInDate
        )
    }
    
    func openIsolationAdvice() {
        context.openURL(ExternalLink.isolationAdvice.url)
    }
    
    func openAdvice() {
        context.openURL(ExternalLink.generalAdvice.url)
    }
    
    func openDailyContactTestingInformation() {
        context.openURL(ExternalLink.dailyContactTestingInformation.url)
    }
    
    func deleteAppData() {
        context.deleteAllData()
    }
    
    func updateVenueHistories(deleting venueHistory: VenueHistory) -> [VenueHistory] {
        venueHistory.delete()
        
        return context.checkInContext?.checkInsStore.load()?.map { checkIn -> VenueHistory in
            VenueHistory(
                id: checkIn.venueId,
                organisation: checkIn.venueName,
                checkedIn: checkIn.checkedIn.date,
                checkedOut: checkIn.checkedOut.date,
                delete: {
                    self.context.deleteCheckIn(checkIn.id)
                }
            )
        } ?? []
    }
    
    func openTearmsOfUseLink() {
        context.openURL(ExternalLink.ourPolicies.url)
    }
    
    func openPrivacyLink() {
        context.openURL(ExternalLink.privacy.url)
    }
    
    func openFAQ() {
        context.openURL(ExternalLink.faq.url)
    }
    
    func openAccessibilityStatementLink() {
        context.openURL(ExternalLink.accessibilityStatement.url)
    }
    
    func openHowThisAppWorksLink() {
        context.openURL(ExternalLink.howThisAppWorks.url)
    }
    
    func openWebsiteLinkfromRisklevelInfoScreen(url: URL) {
        context.openURL(url)
    }
    
    func openProvideFeedbackLink() {
        context.openURL(ExternalLink.provideFeedback.url)
    }
    
}
