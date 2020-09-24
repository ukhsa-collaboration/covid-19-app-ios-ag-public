//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class RawStateTests: XCTestCase {
    
    func testAppStaysInLoadingStateUntilWeKnowNotificationStatus() {
        let rawState = RawState(
            isAppActivated: true,
            appAvailability: .available,
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .unknown,
            hasPostcode: true
        )
        
        XCTAssertEqual(rawState.logicalState, .starting)
    }
    
    func testAppUnavailable() {
        let reasons: [AppAvailabilityLogicalState.UnavailabilityReason] = [
            .iOSTooOld(descriptions: [:]),
            .appTooOld(updateAvailable: true, descriptions: [:]),
            .appTooOld(updateAvailable: false, descriptions: [:]),
        ]
        
        for reason in reasons {
            let rawState = RawState(
                isAppActivated: true,
                appAvailability: .unavailable(reason: reason),
                completedOnboardingForCurrentSession: false,
                exposureState: ExposureNotificationStateController.CombinedState(
                    activationState: .activated,
                    authorizationState: .authorized,
                    exposureNotificationState: .active,
                    isEnabled: true
                ),
                userNotificationsStatus: .authorized,
                hasPostcode: true
            )
            
            XCTAssertEqual(rawState.logicalState, .appUnavailable(reason))
        }
    }
    
    func testRequiringPilotActivation() {
        let rawState = RawState(
            isAppActivated: false,
            appAvailability: .available,
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .unknown,
            hasPostcode: true
        )
        
        XCTAssertEqual(rawState.logicalState, .pilotActivationRequired)
    }
    
    func testCompletedOnboarding() {
        let rawState = RawState(
            isAppActivated: true,
            appAvailability: .available,
            completedOnboardingForCurrentSession: true,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .authorized,
            hasPostcode: true
        )
        
        XCTAssertEqual(rawState.logicalState, .fullyOnboarded)
    }
    
}
