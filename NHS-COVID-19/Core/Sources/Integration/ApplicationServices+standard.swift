//
// Copyright © 2021 DHSC. All rights reserved.
//

import BackgroundTasks
import Common
import Domain
import ExposureNotification
import Foundation
import Logging
import UIKit

extension ApplicationServices {
    
    private static let logger = Logger(label: "ApplicationServices")
    
    public convenience init(
        standardServicesFor environment: Environment,
        dateProvider: DateProviding = DateProvider(),
        exposureNotificationManager: ExposureNotificationManaging = ENManager()
    ) {
        Self.logger.debug("initialising", metadata: .describing(environment.identifier))
        self.init(
            application: UIApplication.shared,
            exposureNotificationManager: exposureNotificationManager,
            userNotificationsManager: UserNotificationManager(),
            processingTaskRequestManager: ProcessingTaskRequestManager(
                identifier: environment.backgroundTaskIdentifier,
                scheduler: BGTaskScheduler.shared
            ),
            notificationCenter: .default,
            distributeClient: environment.distributionClient,
            apiClient: environment.apiClient,
            iTunesClient: environment.iTunesClient,
            cameraManager: CameraManager(),
            encryptedStore: EncryptedStore(service: environment.identifier),
            cacheStorage: MigratoryFileStorage(
                newStorage: FileStorage(forNewCachesOf: environment.identifier),
                oldStorage: FileStorage(forOldCachesOf: environment.identifier)
            ),
            venueDecoder: environment.venueDecoder,
            appInfo: environment.appInfo,
            postcodeValidator: PostcodeValidator(),
            currentDateProvider: dateProvider,
            storeReviewController: StoreReviewController()
        )
    }
    
}
