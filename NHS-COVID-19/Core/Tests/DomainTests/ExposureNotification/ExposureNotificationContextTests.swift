//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class ExposureNotificationContextTests: XCTestCase {
    var services: MockApplicationServices!
    var context: ExposureNotificationContext!
    var isolationContext: IsolationContext!
    
    override func setUp() {
        services = MockApplicationServices()
        
        context = ExposureNotificationContext(
            services: services,
            isolationLength: 3,
            interestedInExposureNotifications: { false },
            getPostcode: { nil },
            getLocalAuthority: { nil }
        )
        
        isolationContext = IsolationContext(
            isolationConfiguration: .init(httpClient: services.apiClient, endpoint: IsolationConfigurationEndpoint(), storage: services.cacheStorage, name: UUID().uuidString, initialValue: .default),
            encryptedStore: services.encryptedStore,
            notificationCenter: services.notificationCenter,
            currentDateProvider: services.currentDateProvider,
            removeExposureDetectionNotifications: {}
        )
    }
    
    func testSendReminderNotificationWhenContactCaseIsolationIsNotAcknowledged() throws {
        isolationContext.isolationStateStore.set(ContactCaseInfo(exposureDay: .today, isolationFromStartOfDay: .today))
        
        try context.resendExposureDetectionNotificationIfNeeded(isolationContext: isolationContext).await().get()
        
        XCTAssertTrue(services.mockUserNotificationsManager.notificationType == .exposureDetection)
    }
    
    // The notification should only be removed if a user acknowledges his isolation due to a risky contact
    // This is currently only possible as contact case only.
    // Revisit this test after changing the logic when to show the "isolate due to risky contact" screen
    func testDoNotSendReminderNotificationWhenNotOnlyContactCase() throws {
        isolationContext.isolationStateStore.set(ContactCaseInfo(exposureDay: .today, isolationFromStartOfDay: .today))
        isolationContext.isolationStateStore.set(IndexCaseInfo(isolationTrigger: .selfDiagnosis(.today), onsetDay: .today, testInfo: nil))
        
        try context.resendExposureDetectionNotificationIfNeeded(isolationContext: isolationContext).await().get()
        
        XCTAssertFalse(services.mockUserNotificationsManager.notificationType == .exposureDetection)
    }
    
    func testDoNotSendReminderNotificationWheOnlyContactCaseIsolationStartAcknowledged() throws {
        isolationContext.isolationStateStore.set(ContactCaseInfo(exposureDay: .today, isolationFromStartOfDay: .today))
        isolationContext.isolationStateStore.acknowldegeStartOfIsolation()
        try context.resendExposureDetectionNotificationIfNeeded(isolationContext: isolationContext).await().get()
        
        XCTAssertFalse(services.mockUserNotificationsManager.notificationType == .exposureDetection)
    }
    
    func testDoNotSendReminderNotificationWheNotIsolating() throws {
        try context.resendExposureDetectionNotificationIfNeeded(isolationContext: isolationContext).await().get()
        
        XCTAssertFalse(services.mockUserNotificationsManager.notificationType == .exposureDetection)
    }
    
    class MockApplicationServices: ApplicationServices {
        let mockUserNotificationsManager: MockUserNotificationsManager
        
        init() {
            let mockUserNotificationsManager = MockUserNotificationsManager()
            self.mockUserNotificationsManager = mockUserNotificationsManager
            super.init(
                application: MockApplication(),
                exposureNotificationManager: MockExposureNotificationManager(),
                userNotificationsManager: mockUserNotificationsManager,
                processingTaskRequestManager: MockProcessingTaskRequestManager(),
                notificationCenter: NotificationCenter(),
                distributeClient: MockHTTPClient(),
                apiClient: MockHTTPClient(),
                iTunesClient: MockHTTPClient(),
                cameraManager: MockCameraManager(),
                encryptedStore: MockEncryptedStore(),
                cacheStorage: FileStorage(forNewCachesOf: UUID().uuidString),
                venueDecoder: QRCode.forTests,
                appInfo: AppInfo(bundleId: .random(), version: "3.10", buildNumber: "1"),
                postcodeValidator: MockPostcodeValidator(),
                currentDateProvider: MockDateProvider(),
                storeReviewController: MockStoreReviewController()
            )
            
        }
    }
    
}
