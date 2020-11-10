//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct ExposureNotificationContext {
    var exposureNotificationStateController: ExposureNotificationStateController
    var exposureNotificationManager: ExposureNotificationManaging
    var exposureDetectionStore: ExposureDetectionStore
    var exposureDetectionManager: ExposureDetectionManager
    var exposureKeysManager: ExposureKeysManager
    
    init(
        exposureNotificationManager: ExposureNotificationManaging,
        encryptedStore: EncryptedStoring,
        isolationLength: DayDuration,
        currentDateProvider: @escaping () -> Date,
        apiClient: HTTPClient,
        distributeClient: HTTPClient,
        cacheStorage: FileStorage,
        interestedInExposureNotifications: @escaping () -> Bool
    ) {
        self.exposureNotificationManager = exposureNotificationManager
        exposureDetectionStore = ExposureDetectionStore(store: encryptedStore)
        let controller = ExposureNotificationDetectionController(manager: exposureNotificationManager)
        
        let exposureRiskManager: ExposureRiskManaging
        if #available(iOS 13.7, *) {
            exposureRiskManager = ExposureWindowRiskManager(
                controller: controller,
                riskCalculator: ExposureWindowRiskCalculator(
                    dateProvider: currentDateProvider,
                    isolationLength: isolationLength
                )
            )
        } else {
            exposureRiskManager = ExposureRiskManager(controller: controller)
        }
        
        exposureKeysManager = ExposureKeysManager(
            controller: controller,
            submissionClient: apiClient
        )
        
        exposureDetectionManager = ExposureDetectionManager(
            controller: controller,
            distributionClient: distributeClient,
            fileStorage: cacheStorage,
            encryptedStore: encryptedStore,
            interestedInExposureNotifications: interestedInExposureNotifications,
            exposureRiskManager: exposureRiskManager
        )
        
        exposureNotificationStateController = ExposureNotificationStateController(manager: exposureNotificationManager)
        exposureNotificationStateController.activate()
    }
}
