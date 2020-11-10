//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

enum LogicalState: Equatable {
    
    enum ExposureDetectionDisabledReason {
        case authorizationDenied
        case bluetoothDisabled
    }
    
    case starting
    case appUnavailable(AppAvailabilityLogicalState.UnavailabilityReason, descriptions: [Locale: String])
    case recommendingUpdate(AppAvailabilityLogicalState.RecommendationReason, titles: [Locale: String], descriptions: [Locale: String])
    case failedToStart
    case onboarding
    case postcodeRequired
    case policyAcceptanceRequired
    case authorizationRequired
    case canNotRunExposureNotification(ExposureDetectionDisabledReason)
    case fullyOnboarded
}

public struct RunningAppContext {
    public var checkInContext: CheckInContext?
    public var postcodeInfo: DomainProperty<(postcode: Postcode, risk: DomainProperty<RiskyPostcodeEndpointManager.PostcodeRisk?>)?>
    public var savePostcode: ((String) -> Result<Void, PostcodeValidationError>)?
    public var country: DomainProperty<Country>
    public var openSettings: () -> Void
    public var openURL: (URL) -> Void
    public var selfDiagnosisManager: SelfDiagnosisManager?
    public var isolationState: DomainProperty<IsolationState>
    public var testInfo: DomainProperty<IndexCaseInfo.TestInfo?>
    public var isolationAcknowledgementState: AnyPublisher<IsolationAcknowledgementState, Never>
    public var exposureNotificationStateController: ExposureNotificationStateControlling
    public var virologyTestingManager: VirologyTestingManaging
    public var testResultAcknowledgementState: AnyPublisher<TestResultAcknowledgementState, Never>
    public var symptomsDateAndEncounterDateProvider: SymptomsOnsetDateAndEncounterDateProviding
    public var deleteAllData: () -> Void
    public var deleteCheckIn: (String) -> Void
    public var riskyCheckInsAcknowledgementState: AnyPublisher<RiskyCheckInsAcknowledgementState, Never>
    public var currentDateProvider: () -> Date
    public var exposureNotificationReminder: ExposureNotificationReminder
    public var appReviewPresenter: AppReviewPresenter
}

public enum ApplicationState {
    
    public enum AppUnavailabilityReason {
        /// OS version is too old for this app
        case iOSTooOld(descriptions: [Locale: String])
        
        /// App version is too old
        case appTooOld(updateAvailable: Bool, descriptions: [Locale: String])
    }
    
    public enum RecommendedUpdateReason {
        /// Recommended App update is availbale
        case newRecommendedAppUpdate(title: [Locale: String], descriptions: [Locale: String], dismissAction: () -> Void)
        
        /// Recommended iOS update is available
        case newRecommendedOSupdate(title: [Locale: String], descriptions: [Locale: String], dismissAction: () -> Void)
    }
    
    public enum ExposureDetectionDisabledReason {
        /// Authorization is denied by the user.
        case authorizationDenied(openSettings: () -> Void)
        
        /// Bluetooth is disabled.
        case bluetoothDisabled
    }
    
    /// Application is starting. This should normally be very quick.
    case starting
    
    /// Application is disabled.
    case appUnavailable(AppUnavailabilityReason)
    
    /// RecommendedUpdate
    case recommmededUpdate(RecommendedUpdateReason)
    
    /// Application can’t finish starting. There’s no standard way for the user to recover from this.
    ///
    /// This can happen, for example, if certain authorization is restricted, or if another app is using ExposureNotification API.
    case failedToStart
    
    /// Application needs to show onboarding.
    case onboarding(complete: () -> Void, openURL: (URL) -> Void)
    
    /// Application requires onboarding.
    case authorizationRequired(requestPermissions: () -> Void, country: DomainProperty<Country>)
    
    /// Application is set up, but can not run exposure detection. See `reason`.
    ///
    /// The user can help the app recover from this.
    case canNotRunExposureNotification(reason: ExposureDetectionDisabledReason, country: Country)
    
    /// Application requires postcode
    case postcodeRequired(savePostcode: (_ postcode: String) -> Result<Void, PostcodeValidationError>)
    
    /// Application requires user acknowledge/acceptance of new policies
    case policyAcceptanceRequired(saveCurrentVersion: () -> Void, openURL: (URL) -> Void)
    
    /// Application is properly set up and is running exposure detection
    case runningExposureNotification(RunningAppContext)
}
