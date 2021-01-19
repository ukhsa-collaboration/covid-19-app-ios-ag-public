//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class RawStateTests: XCTestCase {
    
    func testAppStaysInLoadingStateUntilWeKnowNotificationStatus() {
        let rawState = RawState(
            appAvailability: AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .available),
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .unknown,
            postcodeState: .postcodeAndLocalAuthority,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: false
        )
        
        XCTAssertEqual(rawState.logicalState, .starting)
    }
    
    func testAppUnavailable() {
        let reasons: [AppAvailabilityLogicalState.UnavailabilityReason] = [
            .iOSTooOld,
            .appTooOld(updateAvailable: true),
            .appTooOld(updateAvailable: false),
        ]
        
        for reason in reasons {
            let rawState = RawState(
                appAvailability: AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .unavailable(reason: reason)),
                completedOnboardingForCurrentSession: false,
                exposureState: ExposureNotificationStateController.CombinedState(
                    activationState: .activated,
                    authorizationState: .authorized,
                    exposureNotificationState: .active,
                    isEnabled: true
                ),
                userNotificationsStatus: .authorized,
                postcodeState: .postcodeAndLocalAuthority,
                shouldRecommendUpdate: true,
                shouldShowPolicyUpdate: true
            )
            
            XCTAssertEqual(rawState.logicalState, .appUnavailable(reason, descriptions: [:]))
        }
    }
    
    func testShowPolicyUpdate() {
        let rawState = RawState(
            appAvailability: AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .available),
            completedOnboardingForCurrentSession: true,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .authorized,
            postcodeState: .postcodeAndLocalAuthority,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: true
        )
        
        XCTAssertEqual(rawState.logicalState, .policyAcceptanceRequired)
    }
    
    func testCompletedOnboarding() {
        let rawState = RawState(
            appAvailability: AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .available),
            completedOnboardingForCurrentSession: true,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .authorized,
            postcodeState: .postcodeAndLocalAuthority,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: false
        )
        
        XCTAssertEqual(rawState.logicalState, .fullyOnboarded)
    }
    
    func testShowAppRecommendedUpdate() {
        let appAvailability = AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .recommending(reason: .appOlderThanRecommended(version: Version(major: 1))))
        let rawState = RawState(
            appAvailability: appAvailability,
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .authorized,
            postcodeState: .onlyPostcode,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: true
        )
        
        XCTAssertEqual(rawState.logicalState, .recommendingUpdate(.appOlderThanRecommended(version: Version(major: 1)), titles: [:], descriptions: [:]))
    }
    
    func testShowOSRecommendedUpdate() {
        let appAvailability = AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .recommending(reason: .iOSOlderThanRecommended(version: Version(major: 14))))
        let rawState = RawState(
            appAvailability: appAvailability,
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .authorized,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .authorized,
            postcodeState: .onlyPostcode,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: false
        )
        
        XCTAssertEqual(rawState.logicalState, .recommendingUpdate(.iOSOlderThanRecommended(version: Version(major: 14)), titles: [:], descriptions: [:]))
    }
    
    func testAuthorizationRequiredState() {
        let rawState = RawState(
            appAvailability: AppAvailabilityMetadata(titles: [:], descriptions: [:], state: .available),
            completedOnboardingForCurrentSession: false,
            exposureState: ExposureNotificationStateController.CombinedState(
                activationState: .activated,
                authorizationState: .unknown,
                exposureNotificationState: .active,
                isEnabled: true
            ),
            userNotificationsStatus: .unknown,
            postcodeState: .postcodeAndLocalAuthority,
            shouldRecommendUpdate: true,
            shouldShowPolicyUpdate: false
        )
        
        XCTAssertEqual(rawState.logicalState, .authorizationRequired)
    }
}
