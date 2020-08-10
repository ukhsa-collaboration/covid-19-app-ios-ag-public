//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Scenarios
import XCTest

class ExternalLinkOpeningTests: XCTestCase {
    
    func testOpenExternalLink() throws {
        let application = MockApplication()
        let services = ApplicationServices(
            application: application,
            exposureNotificationManager: MockExposureNotificationManager(),
            userNotificationsManager: MockUserNotificationsManager(),
            processingTaskRequestManager: MockProcessingTaskRequestManager(),
            metricManager: MockMetricManager(),
            notificationCenter: NotificationCenter(),
            distributeClient: MockHTTPClient(),
            apiClient: MockHTTPClient(),
            iTunesClient: MockHTTPClient(),
            cameraManager: MockCameraManager(),
            encryptedStore: MockEncryptedStore(),
            cacheStorage: FileStorage(forCachesOf: .random()),
            venueDecoder: QRCode.forTests,
            appInfo: AppInfo(bundleId: .random(), version: "1")
        )
        
        let coordinator = ApplicationCoordinator(services: services, enabledFeatures: Feature.allCases)
        
        let testOrderWebsite = URL.random()
        let linkOpener: ExternalLinkOpening = coordinator
        linkOpener.openExternalLink(url: testOrderWebsite)
        let openedURL = try XCTUnwrap(application.openedURL)
        XCTAssertEqual(testOrderWebsite.absoluteString, openedURL.absoluteString)
    }
}
