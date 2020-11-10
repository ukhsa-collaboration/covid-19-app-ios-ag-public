//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import CryptoKit
import Domain
import Foundation
import Integration
import UIKit

class SandboxedAppController: AppController {
    
    private let content: CoordinatedAppController
    private let host: SandboxHost
    
    let rootViewController = UIViewController()
    
    init() {
        host = SandboxHost(container: rootViewController, initialState: Sandbox.InitialState())
        content = CoordinatedAppController(sandboxedIn: host)
        rootViewController.addFilling(content.rootViewController)
    }
    
    func performBackgroundTask(task: BackgroundTask) {}
    
}

private extension CoordinatedAppController {
    
    convenience init(sandboxedIn host: SandboxHost) {
        let enabledFeatures = FeatureToggleStorage.getEnabledFeatures()
        let services = ApplicationServices(sandboxedIn: host)
        self.init(services: services, enabledFeatures: enabledFeatures)
    }
    
}

private extension ApplicationServices {
    
    convenience init(sandboxedIn host: SandboxHost) {
        self.init(
            application: MockApplication(),
            exposureNotificationManager: SandboxExposureNotificationManager(host: host),
            userNotificationsManager: SandboxUserNotificationsManager(host: host),
            processingTaskRequestManager: MockProcessingTaskRequestManager(),
            metricManager: MockMetricManager(),
            notificationCenter: NotificationCenter(),
            distributeClient: SandboxDistributeClient(),
            apiClient: SandboxSubmissionClient(),
            iTunesClient: MockHTTPClient(),
            cameraManager: SandboxCameraManager(host: host),
            encryptedStore: SandboxEncryptedStore(host: host),
            cacheStorage: FileStorage(forCachesOf: UUID().uuidString),
            venueDecoder: QRCode.fake,
            appInfo: AppInfo(bundleId: UUID().uuidString, version: "3.10", buildNumber: "1"),
            pasteboardCopier: MockPasteboardCopier(),
            postcodeValidator: SandboxPostcodeValidator(),
            currentDateProvider: { Date() },
            storeReviewController: StoreReviewController()
        )
    }
    
}

private extension P256.Signing.PublicKey {
    
    static let testKey = try! P256.Signing.PublicKey(pemRepresentationCompatibility: """
    -----BEGIN PUBLIC KEY-----
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEVs/o5+uQbTjL3chynL4wXgUg2R9
    q9UU8I5mEovUf86QZ7kOBIjJwqnzD1omageEHWwHdBO6B+dFabmdT9POxg==
    -----END PUBLIC KEY-----
    """)
    
}

private extension QRCode {
    
    static let fake = QRCode(keyId: "3", key: .testKey)
    
}
