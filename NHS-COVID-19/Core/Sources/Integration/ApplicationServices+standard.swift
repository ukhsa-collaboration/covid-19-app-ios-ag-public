//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks
import Common
import Domain
import ExposureNotification
import Foundation
import Logging
import MetricKit
import UIKit

extension ApplicationServices {
    
    private static let logger = Logger(label: "ApplicationServices")
    
    public convenience init(standardServicesFor environment: Environment, exposureNotificationManager: ExposureNotificationManaging = ENManager()) {
        Self.logger.debug("initialising", metadata: .describing(environment.identifier))
        
        self.init(
            application: UIApplication.shared,
            exposureNotificationManager: exposureNotificationManager,
            userNotificationsManager: UserNotificationManager(),
            processingTaskRequestManager: ProcessingTaskRequestManager(
                identifier: environment.backgroundTaskIdentifier,
                scheduler: BGTaskScheduler.shared
            ),
            metricManager: MXMetricManager.shared,
            notificationCenter: .default,
            distributeClient: environment.distributionClient,
            apiClient: environment.apiClient,
            iTunesClient: environment.iTunesClient,
            cameraManager: CameraManager(),
            encryptedStore: EncryptedStore(service: environment.identifier),
            cacheStorage: FileStorage(forCachesOf: environment.identifier),
            venueDecoder: environment.venueDecoder,
            appInfo: AppInfo(for: .main),
            pasteboardCopier: PasteboardCopier(),
            postcodeValidator: PostcodeValidator()
        )
    }
    
}
