//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
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
            removeExposureDetectionNotifications: {},
            scheduleSelfIsolationReminderNotification: {},
            country: Just(Country.england).domainProperty()
        )
    }
    
    func testExposureWindowExpiryDate() throws {
        _ = services.currentDateProvider.today.sink { today in
            let expiredWindowsDay = self.context.expiredWindowsDay
            let distance = expiredWindowsDay.distance(to: today.gregorianDay)
            XCTAssertEqual(distance, ExposureNotificationContext.exposureWindowExpiryDays)
        }
    }
    
    // essentially just checking GregorianDay.advanced(by:)
    func testExpiryDateCalculation() {
        let march15th = Calendar.gregorian.date(from: DateComponents(year: 2021, month: 3, day: 15))!
        let expiryDate = context.calculateExpiredWindowsDay(march15th, offset: -14)
        let expiryDateComponents = expiryDate.dateComponents
        XCTAssertEqual(expiryDateComponents.year, 2021)
        XCTAssertEqual(expiryDateComponents.month, 3)
        XCTAssertEqual(expiryDateComponents.day, 1)
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
        isolationContext.isolationStateStore.set(IndexCaseInfo(symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: .today, onsetDay: .today), testInfo: nil))
        
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
                cacheStorage: FileStorage(forCachesOf: UUID().uuidString),
                venueDecoder: VenueDecoder.forTests,
                appInfo: AppInfo(bundleId: .random(), version: "4.16", buildNumber: "1"),
                postcodeValidator: MockPostcodeValidator(),
                currentDateProvider: MockDateProvider(),
                storeReviewController: MockStoreReviewController(),
                riskyPostcodeUpdateIntervalProvider: DefaultMinimumUpdateIntervalProvider()
            )
            
        }
    }
    
    func testWindowsToSend() {
        
        let windows = [
            ExposureWindowInfo(
                date: GregorianDay(year: 2020, month: 7, day: 7),
                infectiousness: .high,
                scanInstances: [
                    ExposureWindowInfo.ScanInstance(
                        minimumAttenuation: 9,
                        typicalAttenuation: 0,
                        secondsSinceLastScan: 201
                    ),
                ],
                riskScore: 131.44555790888523,
                riskCalculationVersion: 2, isConsideredRisky: false
            ),
            ExposureWindowInfo(
                date: GregorianDay(year: 2020, month: 7, day: 8),
                infectiousness: .high,
                scanInstances: [
                    ExposureWindowInfo.ScanInstance(
                        minimumAttenuation: 97,
                        typicalAttenuation: 0,
                        secondsSinceLastScan: 201
                    ),
                ],
                riskScore: 131.44555790888523,
                riskCalculationVersion: 2, isConsideredRisky: false
            ),
            ExposureWindowInfo(
                date: GregorianDay(year: 2020, month: 7, day: 8),
                infectiousness: .high,
                scanInstances: [
                    ExposureWindowInfo.ScanInstance(
                        minimumAttenuation: 97,
                        typicalAttenuation: 0,
                        secondsSinceLastScan: 201
                    ),
                ],
                riskScore: 131.44555790888523,
                riskCalculationVersion: 2, isConsideredRisky: false
            ),
            ExposureWindowInfo(
                date: GregorianDay(year: 2020, month: 7, day: 8),
                infectiousness: .high,
                scanInstances: [
                    ExposureWindowInfo.ScanInstance(
                        minimumAttenuation: 97,
                        typicalAttenuation: 0,
                        secondsSinceLastScan: 201
                    ),
                ],
                riskScore: 131.44555790888523,
                riskCalculationVersion: 2, isConsideredRisky: true
            ),
        ]
        
        let array = ExposureNotificationContext.windowsToSend(windows, limit: 2)
        XCTAssertEqual(array.riskyWindows.count, 1)
        XCTAssertEqual(array.nonRiskyWindows.count, 2)
    }
}
