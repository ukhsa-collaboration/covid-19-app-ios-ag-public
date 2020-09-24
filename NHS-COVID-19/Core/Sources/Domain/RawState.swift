//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct RawState: Equatable {
    var isAppActivated: Bool
    var appAvailability: AppAvailabilityLogicalState
    var completedOnboardingForCurrentSession: Bool
    var exposureState: ExposureNotificationStateController.CombinedState
    var userNotificationsStatus: UserNotificationsStateController.AuthorizationStatus
    var hasPostcode: Bool
    
    var logicalState: LogicalState {
        let logicalStateIgnoringOnboarding = self.logicalStateIgnoringOnboarding
        switch logicalStateIgnoringOnboarding {
        case .postcodeRequired where !completedOnboardingForCurrentSession, .authorizationRequired where !completedOnboardingForCurrentSession:
            // Show onboarding just before postcode or authorization
            return .onboarding
        default:
            return logicalStateIgnoringOnboarding
        }
    }
    
    private var logicalStateIgnoringOnboarding: LogicalState {
        switch appAvailability {
        case .available:
            return isAppActivated ? postAvailabilityLogicalState : .pilotActivationRequired
        case .unavailable(let reason):
            return .appUnavailable(reason)
        }
    }
    
    private var postAvailabilityLogicalState: LogicalState {
        switch exposureState.activationState {
        case .inactive, .activating:
            return .starting
        case .activationFailed:
            return .failedToStart
        case .activated:
            return postActivationState
        }
    }
    
    private var postActivationState: LogicalState {
        
        switch exposureState.authorizationState {
        case .unknown:
            if hasPostcode {
                return .authorizationRequired
            }
            return .postcodeRequired
        case .restricted:
            return .failedToStart
        case .notAuthorized:
            return .canNotRunExposureNotification(.authorizationDenied)
        case .authorized:
            return postAuthorizedState
        }
    }
    
    private var postAuthorizedState: LogicalState {
        switch exposureState.exposureNotificationState {
        case .unknown:
            assertionFailure("Encountered unknown state after activation. This should not be possible.")
            return .failedToStart
        case .restricted:
            return .failedToStart
        case .bluetoothOff:
            return .canNotRunExposureNotification(.bluetoothDisabled)
        case .active, .disabled:
            switch userNotificationsStatus {
            case .unknown:
                return .starting
            case .notDetermined:
                if hasPostcode {
                    return .authorizationRequired
                }
                return .postcodeRequired
            case .authorized, .denied:
                if hasPostcode {
                    return .fullyOnboarded
                }
                return .postcodeRequired
            }
        }
    }
    
}
