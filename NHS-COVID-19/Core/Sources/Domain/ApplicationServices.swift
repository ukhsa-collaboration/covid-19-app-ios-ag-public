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
    let notificationCenter: NotificationCenter
    let distributeClient: HTTPClient
    let apiClient: HTTPClient
    let iTunesClient: HTTPClient
    let cameraManager: CameraManaging
    let encryptedStore: EncryptedStoring
    let cacheStorage: FileStorage
    let venueDecoder: QRCode
    let appInfo: AppInfo
    let postcodeValidator: PostcodeValidating
    let currentDateProvider: DateProviding
    let storeReviewController: StoreReviewControlling
    
    public init(
        application: Application,
        exposureNotificationManager: ExposureNotificationManaging,
        userNotificationsManager: UserNotificationManaging,
        processingTaskRequestManager: ProcessingTaskRequestManaging,
        notificationCenter: NotificationCenter,
        distributeClient: HTTPClient,
        apiClient: HTTPClient,
        iTunesClient: HTTPClient,
        cameraManager: CameraManaging,
        encryptedStore: EncryptedStoring,
        cacheStorage: FileStorage,
        venueDecoder: QRCode,
        appInfo: AppInfo,
        postcodeValidator: PostcodeValidating,
        currentDateProvider: DateProviding,
        storeReviewController: StoreReviewControlling
    ) {
        self.application = application
        self.exposureNotificationManager = exposureNotificationManager
        self.userNotificationsManager = userNotificationsManager
        self.processingTaskRequestManager = processingTaskRequestManager
        self.notificationCenter = notificationCenter
        self.distributeClient = distributeClient
        self.apiClient = apiClient
        self.iTunesClient = iTunesClient
        self.cameraManager = cameraManager
        self.encryptedStore = encryptedStore
        self.cacheStorage = cacheStorage
        self.venueDecoder = venueDecoder
        self.appInfo = appInfo
        self.postcodeValidator = postcodeValidator
        self.currentDateProvider = currentDateProvider
        self.storeReviewController = storeReviewController
    }
    
}
