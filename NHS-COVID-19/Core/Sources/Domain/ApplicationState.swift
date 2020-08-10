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
    case appUnavailable(AppAvailabilityLogicalState.UnavailabilityReason)
    case pilotActivationRequired
    case failedToStart
    case authorizationOnboarding
    case canNotRunExposureNotification(ExposureDetectionDisabledReason)
    case postcodeOnboarding
    case fullyOnboarded
}

public struct RunningAppContext {
    public var checkInContext: CheckInContext?
    public var postcodeStore: PostcodeStore?
    public var openSettings: () -> Void
    public var selfDiagnosisManager: SelfDiagnosisManager?
    public var isolationState: DomainProperty<IsolationState>
    public var testInfo: DomainProperty<IndexCaseInfo.TestInfo?>
    public var isolationAcknowledgementState: AnyPublisher<IsolationAcknowledgementState, Never>
    public var exposureNotificationStateController: ExposureNotificationStateControlling
    public var virologyTestOrderInfoProvider: VirologyTestingTestOrderInfoProviding
    public var testResultAcknowledgementState: AnyPublisher<TestResultAcknowledgementState, Never>
    public var symptomsDateAndEncounterDateProvider: SymptomsOnsetDateAndEncounterDateProviding
    public var deleteAllData: () -> Void
    public var riskyCheckInsAcknowledgementState: AnyPublisher<RiskyCheckInsAcknowledgementState, Never>
}

public enum ApplicationState {
    
    public enum AppUnavailabilityReason {
        /// OS version is too old for this app
        case iOSTooOld(descriptions: [Locale: String])
        
        /// App version is too old
        case appTooOld(updateAvailable: Bool, descriptions: [Locale: String])
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
    
    /// The user must activate this app first
    case pilotActivationRequired(submit: (String) -> AnyPublisher<Void, Error>)
    
    /// Application can’t finish starting. There’s no standard way for the user to recover from this.
    ///
    /// This can happen, for example, if certain authorization is restricted, or if another app is using ExposureNotification API.
    case failedToStart
    
    /// Application requires onboarding.
    case authorizationOnboarding(requestPermissions: () -> Void)
    
    /// Application is set up, but can not run exposure detection. See `reason`.
    ///
    /// The user can help the app recover from this.
    case canNotRunExposureNotification(reason: ExposureDetectionDisabledReason)
    
    /// Application requires postcode
    case postcodeOnboarding(savePostcode: (_ postcode: String) throws -> Void)
    
    /// Application is properly set up and is running exposure detection
    case runningExposureNotification(RunningAppContext)
}
