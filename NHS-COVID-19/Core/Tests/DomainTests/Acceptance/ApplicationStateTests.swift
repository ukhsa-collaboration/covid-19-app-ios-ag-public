//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

class ApplicationStateTests: XCTestCase {
    
    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var application = MockApplication()
            var enabledFeatures = Feature.allCases
            var exposureNotificationManager = MockExposureNotificationManager()
            var userNotificationsManager = MockUserNotificationsManager()
            var processingTaskRequestManager = MockProcessingTaskRequestManager()
            var notificationCenter = NotificationCenter()
            var distributeClient = MockHTTPClient()
            var apiClient = MockHTTPClient()
            var iTunesClient = MockHTTPClient()
            var cameraManager = MockCameraManager()
            var encryptedStore = MockEncryptedStore()
            var cacheStorage = FileStorage(forCachesOf: .random())
        }
        
        var coordinator: ApplicationCoordinator
        
        init(configuration: Configuration) {
            configuration.encryptedStore.stored["activation"] = """
            { "isActivated": true }
            """.data(using: .utf8)!
            let services = ApplicationServices(
                application: configuration.application,
                exposureNotificationManager: configuration.exposureNotificationManager,
                userNotificationsManager: configuration.userNotificationsManager,
                processingTaskRequestManager: configuration.processingTaskRequestManager,
                metricManager: MockMetricManager(),
                notificationCenter: configuration.notificationCenter,
                distributeClient: configuration.distributeClient,
                apiClient: configuration.apiClient,
                iTunesClient: configuration.iTunesClient,
                cameraManager: configuration.cameraManager,
                encryptedStore: configuration.encryptedStore,
                cacheStorage: configuration.cacheStorage,
                venueDecoder: QRCode.forTests,
                appInfo: AppInfo(bundleId: .random(), version: "1"),
                pasteboardCopier: MockPasteboardCopier(),
                postcodeValidator: PostcodeValidator(validPostcodes: ["B44"])
            )
            
            coordinator = ApplicationCoordinator(services: services, enabledFeatures: configuration.enabledFeatures)
        }
    }
    
    @Propped
    private var instance: Instance
    
    private var application: MockApplication {
        $instance.application
    }
    
    private var exposureNotificationManager: MockExposureNotificationManager {
        $instance.exposureNotificationManager
    }
    
    private var userNoticationsManager: MockUserNotificationsManager {
        $instance.userNotificationsManager
    }
    
    private var notificationCenter: NotificationCenter {
        $instance.notificationCenter
    }
    
    private var encryptedStore: MockEncryptedStore {
        $instance.encryptedStore
    }
    
    private var coordinator: ApplicationCoordinator {
        instance.coordinator
    }
    
    private var cancellabes = [AnyCancellable]()
    
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
        
        guard case .canNotRunExposureNotification(.authorizationDenied(let openSettings)) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        openSettings()
        
        XCTAssertEqual(application.openedURL?.absoluteString, application.instanceOpenSettingsURLString)
    }
    
    func testEnteringOnboardingStateAfterSuccessfulActivation() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .authorizationOnboarding(let requestPermissions, let openUrl) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let url = ExternalLink.privacy.url
        openUrl(url)
        
        XCTAssertEqual(application.openedURL, url)
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .postcodeOnboarding = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringErrorStateIfBluetoothDisabled() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .bluetoothOff)
        
        guard case .canNotRunExposureNotification(.bluetoothDisabled) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringOnboardingStateAfterExposureNotificationDisabled() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .disabled)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .authorizationOnboarding(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .postcodeOnboarding = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testEnteringPostcodeOnboardingAfterSuccessfulPermissionOnboarding() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .active)
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .postcodeOnboarding = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    // MARK: - User Notifications Authorization Status
    
    func testAuthorizedUserNotificationsState() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .active)
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .postcodeOnboarding = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testDeniedUserNotificationsState() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .active)
        try completeUserNotificationsAuthorization(authorizationStatus: .denied)
        
        guard case .postcodeOnboarding = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func testUserCanAuthorizeUserNotifications() throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .authorizationOnboarding(let requestPermissions, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        requestPermissions()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        enableExposureNotification()
        exposureNotificationManager.activationCompletionHandler?(nil)
        
        guard case .authorizationOnboarding = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        
        guard case .postcodeOnboarding = coordinator.state else {
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
                "diagnosisKeySubmissionToken":"\#(submissionToken)"
            }
        }
        """# .data(using: .utf8)
        try completeRunning()
        
        guard case .runningExposureNotification(let context) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        
        let testResultAcknowledgementState = try testResultAcknowledgementStateResult.get()
        
        guard case .neededForNegativeResultNoIsolation = testResultAcknowledgementState else {
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
                "diagnosisKeySubmissionToken":"\#(submissionToken)"
            }
        }
        """# .data(using: .utf8)
        
        try completeRunning()
        
        guard case .runningExposureNotification(let context) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        let testResultAcknowledgementStateResult = try context.testResultAcknowledgementState.await()
        
        let testResultAcknowledgementState = try testResultAcknowledgementStateResult.get()
        
        guard case .neededForNegativeResult = testResultAcknowledgementState else {
            throw TestError("Unexpected state \(testResultAcknowledgementState)")
        }
    }
}

private extension ApplicationStateTests {
    
    private func completeRunning() throws {
        try completeExposureNotificationActivation(authorizationStatus: .authorized, status: .active)
        try completeUserNotificationsAuthorization(authorizationStatus: .authorized)
        guard case .postcodeOnboarding(let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        try savePostcode("B44")
    }
    
    private func completeExposureNotificationActivation(
        authorizationStatus: ExposureNotificationManaging.AuthorizationStatus,
        status: ExposureNotificationManaging.Status = .unknown
    ) throws {
        guard case .starting = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        exposureNotificationManager.instanceAuthorizationStatus = authorizationStatus
        exposureNotificationManager.exposureNotificationStatus = status
        exposureNotificationManager.exposureNotificationEnabled = (status == .active)
        exposureNotificationManager.activationCompletionHandler?(nil)
    }
    
    private func completeUserNotificationsAuthorization(
        authorizationStatus: MockUserNotificationsManager.AuthorizationStatus
    ) throws {
        notificationCenter.post(Notification(name: UIApplication.didBecomeActiveNotification))
        userNoticationsManager.getSettingsCompletionHandler?(authorizationStatus)
    }
    
    private func enableExposureNotification(file: StaticString = #file, line: UInt = #line) {
        // since this is KVO notified, make sure the manager has actually asked us about this before we change values
        XCTAssertEqual(exposureNotificationManager.setExposureNotificationEnabledValue, true, "Did not ask for state update", file: file, line: line)
        exposureNotificationManager.exposureNotificationStatus = .active
        exposureNotificationManager.exposureNotificationEnabled = true
        exposureNotificationManager.setExposureNotificationEnabledCompletionHandler?(nil)
    }
    
}
