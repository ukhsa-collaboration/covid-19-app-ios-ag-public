//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

class ApplicationStateTests: AcceptanceTestCase {
    
    // MARK: - Exposure Notification Activation state
    
    func testEnteringErrorStateIfActivationFails() throws {
        guard case .starting = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        exposureNotificationManager.activationCompletionHandler?(TestError(""))
        
        guard case .failedToStart = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringErrorStateIfOnARestrictedDevice() throws {
        try completeExposureNotificationActivation(authorizationStatus: .restricted)
        
        guard case .failedToStart = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringErrorStateIfAuthorizationDenied() throws {
        try completeExposureNotificationActivation(authorizationStatus: .notAuthorized)
        
        guard case .canNotRunExposureNotification(.authorizationDenied(let openSettings), _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        openSettings()
        
        XCTAssertEqual(application.openedURL?.absoluteString, application.instanceOpenSettingsURLString)
    }
    
    func testEnteringOnboardingStateAfterSuccessfulActivation() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, let openUrl) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let url = URL(string: "https://example.com")!
        openUrl(url)
        
        XCTAssertEqual(application.openedURL, url)
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringErrorStateIfBluetoothDisabled() throws {
        try completeRunningWithBluetoothDisabled()
        
        guard case .canNotRunExposureNotification(.bluetoothDisabled, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringOnboardingStateAfterExposureNotificationDisabled() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .disabled)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testDeniedUserNotificationsState() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        
        try completeUserNotificationsAuthorization(authorizationStatus: .denied)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testUserCanAuthorizeUserNotifications() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .authorizationRequired(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    // MARK: - User Notifications Authorization Status
    
    func testABackgroundTaskIsScheduledWhenRunningExposureNotification() throws {
        try completeRunning()
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        XCTAssertNotNil($instance.processingTaskRequestManager.request)
    }
    
    func testNegativeTestResultInIndexCaseGoesToNeededForNegativeResultNoIsolation() throws {
        let now = LocalDay.today
        
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.negative
        
        let endDay = now.advanced(by: -2)
        
        encryptedStore.stored["virology_testing"] = #"""
        {
            "tokensInfo":[
                {
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "pollingToken":"\#(pollingToken)"
                }
            ],
            "latestUnacknowledgedTestResult":{
                "result":"\#(result.rawValue)",
                "endDate":\#(endDay.startOfDay.timeIntervalSinceReferenceDate),
                "diagnosisKeySubmissionToken":"\#(submissionToken)",
                "requiresConfirmatoryTest":false
            }
        }
        """# .data(using: .utf8)
        try completeRunning()
        
        guard case .runningExposureNotification(let context) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        
        let testResultAcknowledgementState = try testResultAcknowledgementStateResult.get()
        
        guard case .neededForNegativeResultNotIsolating = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }
    
    func testNegativeTestResultInBothCasesGoesToNeededForNegativeResult() throws {
        #warning("Need to make sure we eventually inject date everywhere")
        let now = LocalDay.today
        let contactExposureDay = now.advanced(by: -5)
        let contactIsolationStart = now.advanced(by: -4)
        let onsetDay = now.advanced(by: -2)
        
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.negative
        
        encryptedStore.stored["isolation_state_info"] = #"""
        {
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "isolationInfo" : {
                "hasAcknowledgedEndOfIsolation": false,
                "hasAcknowledgedStartOfIsolation": true,
                "contactCaseInfo" : {
                    "exposureDay" : {
                        "day" : \#(contactExposureDay.gregorianDay.dateComponents.day!),
                        "month" : \#(contactExposureDay.gregorianDay.dateComponents.month!),
                        "year" : \#(contactExposureDay.gregorianDay.dateComponents.year!)
                    },
                    "isolationFromStartOfDay":{
                        "day" : \#(contactIsolationStart.gregorianDay.dateComponents.day!),
                        "month" : \#(contactIsolationStart.gregorianDay.dateComponents.month!),
                        "year" : \#(contactIsolationStart.gregorianDay.dateComponents.year!)
                    }
                },
                "indexCaseInfo" : {
                    "selfDiagnosisDay" : {
                        "day" : \#(now.gregorianDay.dateComponents.day!),
                        "month" : \#(now.gregorianDay.dateComponents.month!),
                        "year" : \#(now.gregorianDay.dateComponents.year!)
                    },
                    "onsetDay" : {
                        "day" : \#(onsetDay.gregorianDay.dateComponents.day!),
                        "month" : \#(onsetDay.gregorianDay.dateComponents.month!),
                        "year" : \#(onsetDay.gregorianDay.dateComponents.year!)
                    }
                }
            }
        }
        """# .data(using: .utf8)
        
        let endDay = now.advanced(by: 5)
        
        encryptedStore.stored["virology_testing"] = #"""
        {
            "tokensInfo":[
                {
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "pollingToken":"\#(pollingToken)"
                }
            ],
            "latestUnacknowledgedTestResult":{
                "result":"\#(result.rawValue)",
                "endDate":\#(endDay.startOfDay.timeIntervalSinceReferenceDate),
                "diagnosisKeySubmissionToken":"\#(submissionToken)",
                "requiresConfirmatoryTest":false
            }
        }
        """# .data(using: .utf8)
        
        try completeRunning()
        
        guard case .runningExposureNotification(let context) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        
        let testResultAcknowledgementState = try testResultAcknowledgementStateResult.get()
        
        guard case .neededForNegativeResultContinueToIsolate = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }
    
    func testRiskyPostcodesInvalidatedOnDeleteAllData() throws {
        distributeClient.response(
            for: "/distribution/risky-post-districts-v2",
            response: RiskyPostDistrictsHandler.response([.yellow: .init(postcodes: ["B44"])])
        )
        
        // Complete onboarding
        try completeRunning()
        
        let riskColorBeforeRefresh = try context().postcodeInfo.currentValue?.risk.currentValue?.style.colorScheme
        
        XCTAssertEqual(riskColorBeforeRefresh, .yellow, "Postcode B44 not considered 'yellow' risk when it should be")
        
        // change the data on the 'server.'
        // B44 is now going into a red tier
        distributeClient.response(
            for: "/distribution/risky-post-districts-v2",
            response: RiskyPostDistrictsHandler.response([.red: .init(postcodes: ["B44"])])
        )
        
        // Delete all data and complete re-onboarding.
        // Should trigger a re-download of the risky post districts.
        try context().deleteAllData()
        try completeReOnboarding()
        
        let riskColorAfterRefresh = try context().postcodeInfo.currentValue?.risk.currentValue?.style.colorScheme
        
        XCTAssertEqual(riskColorAfterRefresh, .red, "Postcode B44 should be considered 'red' risk. Maybe it was not reloaded properly?")
        
    }
    
    func testRiskyPostcodesInvalidatedOnChangePostcode() throws {
        
        distributeClient.response(
            for: "/distribution/risky-post-districts-v2",
            response: RiskyPostDistrictsHandler.response([.yellow: .init(postcodes: ["B44"])])
        )
        
        // Complete onboarding
        try completeRunning()
        
        let riskColorBeforeRefresh = try context().postcodeInfo.currentValue?.risk.currentValue?.style.colorScheme
        
        XCTAssertEqual(riskColorBeforeRefresh, .yellow)
        
        // change the data on the 'server.'
        // B44 is now going into a red tier
        distributeClient.response(
            for: "/distribution/risky-post-districts-v2",
            response: RiskyPostDistrictsHandler.response([.red: .init(postcodes: ["B44"])])
        )
        
        // 'Change' the local authority. Even though we're
        // setting it to the same value, setting the local authority
        // should trigger a re-download of the risky post districts.
        let newLocalAuthority = try context().getLocalAuthorities(Postcode("B44")).get().first!
        try _ = context().storeLocalAuthorities(Postcode("B44"), newLocalAuthority)
        
        let riskColorAfterRefresh = try context().postcodeInfo.currentValue?.risk.currentValue?.style.colorScheme
        
        XCTAssertEqual(riskColorAfterRefresh, .red, "Postcode B44 should be considered 'red' risk. Maybe it was not reloaded properly?")
        
    }
    
    func testRiskyPostcodesManagerRateLimitsDownloads() throws {
        
        distributeClient.response(
            for: "/distribution/risky-post-districts-v2",
            response: RiskyPostDistrictsHandler.response([.yellow: .init(postcodes: ["B44"])])
        )
        
        // Complete onboarding
        try completeRunning()
        
        let riskColorBeforeRefresh = try context().postcodeInfo.currentValue?.risk.currentValue?.style.colorScheme
        XCTAssertEqual(riskColorBeforeRefresh, .yellow)
        
        // update the client
        distributeClient.response(
            for: "/distribution/risky-post-districts-v2",
            response: RiskyPostDistrictsHandler.response([.red: .init(postcodes: ["B44"])])
        )
        
        // trigger an update
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // confirm that we didn't fetch the new content as it's been too soon since the last call
        let riskColorAfterRefresh = try context().postcodeInfo.currentValue?.risk.currentValue?.style.colorScheme
        XCTAssertEqual(riskColorAfterRefresh, .yellow)
        
        // advance the clock 11 minutes
        currentDateProvider.setDate(currentDateProvider.currentDate.addingTimeInterval(11 * 60))
        
        // trigger an update
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // this time confirm it's been updated
        let riskColorAfterRefresh2 = try context().postcodeInfo.currentValue?.risk.currentValue?.style.colorScheme
        XCTAssertEqual(riskColorAfterRefresh2, .red)
    }
}
