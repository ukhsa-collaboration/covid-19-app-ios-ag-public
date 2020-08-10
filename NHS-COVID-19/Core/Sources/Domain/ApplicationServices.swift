//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public class ApplicationServices {
    
    let application: Application
    let exposureNotificationManager: ExposureNotificationManaging
    let userNotificationsManager: UserNotificationManaging
    let processingTaskRequestManager: ProcessingTaskRequestManaging
    let metricManager: MetricManaging
    let notificationCenter: NotificationCenter
    let distributeClient: HTTPClient
    let apiClient: HTTPClient
    let iTunesClient: HTTPClient
    let cameraManager: CameraManaging
    let encryptedStore: EncryptedStoring
    let cacheStorage: FileStorage
    let venueDecoder: QRCode
    let appInfo: AppInfo
    
    public init(
        application: Application,
        exposureNotificationManager: ExposureNotificationManaging,
        userNotificationsManager: UserNotificationManaging,
        processingTaskRequestManager: ProcessingTaskRequestManaging,
        metricManager: MetricManaging,
        notificationCenter: NotificationCenter,
        distributeClient: HTTPClient,
        apiClient: HTTPClient,
        iTunesClient: HTTPClient,
        cameraManager: CameraManaging,
        encryptedStore: EncryptedStoring,
        cacheStorage: FileStorage,
        venueDecoder: QRCode,
        appInfo: AppInfo
    ) {
        self.application = application
        self.exposureNotificationManager = exposureNotificationManager
        self.userNotificationsManager = userNotificationsManager
        self.processingTaskRequestManager = processingTaskRequestManager
        self.metricManager = metricManager
        self.notificationCenter = notificationCenter
        self.distributeClient = distributeClient
        self.apiClient = apiClient
        self.iTunesClient = iTunesClient
        self.cameraManager = cameraManager
        self.encryptedStore = encryptedStore
        self.cacheStorage = cacheStorage
        self.venueDecoder = venueDecoder
        self.appInfo = appInfo
    }
    
}
