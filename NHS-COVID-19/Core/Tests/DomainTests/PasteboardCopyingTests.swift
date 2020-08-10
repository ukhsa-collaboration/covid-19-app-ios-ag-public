//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Scenarios
import UIKit
import XCTest

class PasteboardCopyingTests: XCTestCase {
    
    func testOpenExternalLink() throws {
        let services = ApplicationServices(
            application: MockApplication(),
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
        
        let referenceCode = String.random()
        let pasteboardCopier: PasteboardCopying = coordinator
        pasteboardCopier.copyToPasteboard(value: referenceCode)
        
        XCTAssertEqual(UIPasteboard.general.string, referenceCode)
        
    }
}
