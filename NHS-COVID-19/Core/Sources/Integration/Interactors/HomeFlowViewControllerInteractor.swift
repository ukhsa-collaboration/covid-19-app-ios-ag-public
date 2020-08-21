//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import UIKit

struct HomeFlowViewControllerInteractor: HomeFlowViewController.Interacting {
    
    var context: RunningAppContext
    var pasteboardCopier: PasteboardCopying
    
    var riskLevelInfoViewModel: RiskLevelInfoViewModel? {
        if let riskLevel = context.postcodeStore?.riskLevel, let postcode = context.postcodeStore?.load() {
            let riskLevelInfo: RiskLevelInfoViewModel.RiskLevel
            
            switch riskLevel {
            case .low: riskLevelInfo = .low
            case .medium: riskLevelInfo = .medium
            case .high: riskLevelInfo = .high
            }
            
            return RiskLevelInfoViewModel(postcode: postcode, riskLevel: riskLevelInfo)
        }
        return nil
    }
    
    func makeDiagnosisViewController() -> UIViewController? {
        WrappingViewController {
            SelfDiagnosisOrderFlowState.makeState(context: context, pasteboardCopier: pasteboardCopier)
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
            _requestCameraAccess: {
                checkInContext.cameraStateController.requestAccess()
            },
            _createCaptureSession: { resultHandler in
                self.context.qrCodeScanner.createCaptureSession(resultHandler: resultHandler)
            },
            _process: {
                let (venueName, removeCurrentCheckIn) = try checkInContext.checkInsStore.checkIn(with: $0)
                return CheckInDetail(venueName: venueName, removeCurrentCheckIn: removeCurrentCheckIn)
            }
        )
        
        let cameraPermissionStatePublisher = checkInContext.cameraStateController.$authorizationState.map { state -> CameraPermissionState in
            switch state {
            case .notDetermined:
                return .notDetermined
            case .authorized:
                return .authorized
            case .denied, .restricted:
                return .denied
            }
        }.eraseToAnyPublisher()
        
        return CheckInFlowViewController(
            cameraPermissionState: cameraPermissionStatePublisher,
            interactor: interactor
        )
    }
    
    func makeTestingInformationViewController() -> UIViewController? {
        WrappingViewController {
            BookATestFlowState.makeState(context: context, pasteboardCopier: pasteboardCopier)
                .map { state in
                    switch state {
                    case .bookATest(let interactor):
                        return UINavigationController(rootViewController: BookATestInfoViewController(interactor: interactor, shouldHaveCancelButton: true))
                    case .testOrdering(let interactor):
                        return VirologyTestingFlowViewController(interactor)
                    }
                }
        }
    }
    
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        context.exposureNotificationStateController.setEnabled(enabled)
    }
    
    var shouldShowCheckIn: Bool {
        context.checkInContext != nil
    }
    
    func getAppData() -> AppData {
        let venueHistories = context.checkInContext?.checkInsStore.load()?.map { checkIn -> VenueHistory in
            VenueHistory(
                id: checkIn.venueId,
                organisation: checkIn.venueName,
                checkedIn: checkIn.checkedIn.date,
                checkedOut: checkIn.checkedOut.date
            )
        } ?? []
        
        let testResult = context.testInfo.currentValue.map {
            (Interface.TestResult(domainTestResult: $0.result), $0.receivedOnDay.startDate(in: .current))
        }
        
        let symptomsOnsetDate = context.symptomsDateAndEncounterDateProvider.provideSymptomsOnsetDate()
        let encounterDate = context.symptomsDateAndEncounterDateProvider.provideEncounterDate()
        
        return AppData(
            postcode: context.postcodeStore?.load(),
            testResult: testResult,
            venueHistory: venueHistories,
            symptomsOnsetDate: symptomsOnsetDate,
            encounterDate: encounterDate
        )
    }
    
    func openIsolationAdvice() {
        context.openURL(ExternalLink.isolationAdvice.url)
    }
    
    func openAdvice() {
        context.openURL(ExternalLink.generalAdvice.url)
    }
    
    func deleteAppData() {
        context.deleteAllData()
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
    
    func openWebsiteLinkfromRisklevelInfoScreen() {
        context.openURL(ExternalLink.moreInfoOnPostcodeRisk.url)
    }
    
}
