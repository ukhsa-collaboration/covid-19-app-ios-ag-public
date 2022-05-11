//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

class AcceptanceTestCase: XCTestCase {
    
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
            var postcodeValidator = mutating(MockPostcodeValidator()) {
                $0.validPostcodes = [Postcode("B44")]
            }
            
            var appInfo = AppInfo(bundleId: .random(), version: "4.16", buildNumber: "1")
            
            var currentDateProvider = AcceptanceTestMockDateProvider()
            
            var postcode = Postcode("S1")
            var localAuthority = LocalAuthority(name: "Sheffield", id: .init("E08000019"))
        }
        
        var coordinator: ApplicationCoordinator
        var exposureNotificationContext: ExposureNotificationContext
        let postcode: Postcode
        let localAuthority: LocalAuthority
        
        init(configuration: Configuration) {
            configuration.encryptedStore.stored["activation"] = """
            { "isActivated": true }
            """.data(using: .utf8)!
            
            let postcode = configuration.postcode
            let localAuthority = configuration.localAuthority
            
            self.postcode = postcode
            self.localAuthority = localAuthority
            
            let services = ApplicationServices(
                application: configuration.application,
                exposureNotificationManager: configuration.exposureNotificationManager,
                userNotificationsManager: configuration.userNotificationsManager,
                processingTaskRequestManager: configuration.processingTaskRequestManager,
                notificationCenter: configuration.notificationCenter,
                distributeClient: configuration.distributeClient,
                apiClient: configuration.apiClient,
                iTunesClient: configuration.iTunesClient,
                cameraManager: configuration.cameraManager,
                encryptedStore: configuration.encryptedStore,
                cacheStorage: configuration.cacheStorage,
                venueDecoder: VenueDecoder.forTests,
                appInfo: configuration.appInfo,
                postcodeValidator: configuration.postcodeValidator,
                currentDateProvider: configuration.currentDateProvider,
                storeReviewController: MockStoreReviewController(),
                riskyPostcodeUpdateIntervalProvider: DefaultMinimumUpdateIntervalProvider()
            )
            
            exposureNotificationContext = ExposureNotificationContext(services: services, isolationLength: DayDuration(9), interestedInExposureNotifications: { false }, getPostcode: { postcode }, getLocalAuthority: { localAuthority.id })
            coordinator = ApplicationCoordinator(services: services, enabledFeatures: configuration.enabledFeatures)
        }
    }
    
    @Propped
    var instance: Instance
    
    var application: MockApplication {
        $instance.application
    }
    
    var exposureNotificationManager: MockExposureNotificationManager {
        $instance.exposureNotificationManager
    }
    
    var userNoticationsManager: MockUserNotificationsManager {
        $instance.userNotificationsManager
    }
    
    var notificationCenter: NotificationCenter {
        $instance.notificationCenter
    }
    
    var encryptedStore: MockEncryptedStore {
        $instance.encryptedStore
    }
    
    var apiClient: MockHTTPClient {
        $instance.apiClient
    }
    
    var distributeClient: MockHTTPClient {
        $instance.distributeClient
    }
    
    var currentDateProvider: AcceptanceTestMockDateProvider {
        $instance.currentDateProvider
    }
    
    var coordinator: ApplicationCoordinator {
        instance.coordinator
    }
    
    var exposureNotificationContext: ExposureNotificationContext {
        instance.exposureNotificationContext
    }
    
    var postcode: Postcode {
        instance.postcode
    }
    
    var localAuthority: LocalAuthority {
        instance.localAuthority
    }
    
    var appInfo: AppInfo {
        $instance.appInfo
    }
}

extension AcceptanceTestCase {
    
    func resetInstance() {
        _instance.reset()
    }
    
    func completeRunning(postcode: String = "B44", localAuthority: LocalAuthority = LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)) throws {
        try completeExposureNotificationActivation(authorizationStatus: .unknown)
        try completeUserNotificationsAuthorization(authorizationStatus: .notDetermined)
        
        guard case .onboarding(let complete, _, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init(postcode), localAuthority).get()
        
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
    
    func completeReOnboarding() throws {
        
        guard case .onboarding(let complete, _, _) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        complete()
        
        guard case .postcodeAndLocalAuthorityRequired(_, _, let savePostcode) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        
        try savePostcode(.init("B44"), LocalAuthority(name: "Local Authority 1", id: .init("LA1"), country: .england)).get()
        
        guard case .runningExposureNotification = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }
    
    func completeExposureNotificationActivation(
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
    
    func completeUserNotificationsAuthorization(
        authorizationStatus: MockUserNotificationsManager.AuthorizationStatus
    ) throws {
        notificationCenter.post(Notification(name: UIApplication.didBecomeActiveNotification))
        userNoticationsManager.getSettingsCompletionHandler?(authorizationStatus)
    }
    
    func enableExposureNotification(file: StaticString = #file, line: UInt = #line, finalState: ExposureNotificationManaging.Status = .active) {
        // since this is KVO notified, make sure the manager has actually asked us about this before we change values
        XCTAssertEqual(exposureNotificationManager.setExposureNotificationEnabledValue, true, "Did not ask for state update", file: file, line: line)
        exposureNotificationManager.exposureNotificationStatus = finalState
        exposureNotificationManager.exposureNotificationEnabled = true
        exposureNotificationManager.setExposureNotificationEnabledCompletionHandler?(nil)
    }
    
    func context() throws -> RunningAppContext {
        guard case .runningExposureNotification(let context) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
        return context
    }
}
