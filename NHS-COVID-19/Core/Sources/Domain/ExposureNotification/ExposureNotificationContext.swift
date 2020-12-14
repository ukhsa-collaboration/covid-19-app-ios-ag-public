//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

struct ExposureNotificationContext {
    var exposureNotificationStateController: ExposureNotificationStateController
    var exposureNotificationManager: ExposureNotificationManaging
    var exposureDetectionStore: ExposureDetectionStore
    var exposureDetectionManager: ExposureDetectionManager
    var exposureKeysManager: ExposureKeysManager
    var diagnosisKeyCacheHouskeeper: DiagnosisKeyCacheHousekeeper
    var handleDontWorryNotification: () -> Void
    var exposureWindowAnalyticsHandler: ExposureWindowAnalyticsHandler?
    var currentDateProvider: DateProviding
    var exposureWindowStore: ExposureWindowStore?
    var trafficObfuscationClient: TrafficObfuscationClient
    
    init(
        services: ApplicationServices,
        isolationLength: DayDuration,
        interestedInExposureNotifications: @escaping () -> Bool,
        getPostcode: @escaping () -> Postcode?
    ) {
        exposureNotificationManager = services.exposureNotificationManager
        currentDateProvider = services.currentDateProvider
        
        exposureDetectionStore = ExposureDetectionStore(store: services.encryptedStore)
        let controller = ExposureNotificationDetectionController(manager: services.exposureNotificationManager)
        
        let trafficObfuscationClient = TrafficObfuscationClient(client: services.apiClient)
        self.trafficObfuscationClient = trafficObfuscationClient
        
        let exposureRiskManager: ExposureRiskManaging
        if #available(iOS 13.7, *) {
            let exposureWindowAnalyticsHandler = ExposureWindowAnalyticsHandler()
            self.exposureWindowAnalyticsHandler = exposureWindowAnalyticsHandler
            
            exposureRiskManager = ExposureWindowRiskManager(
                controller: controller,
                riskCalculator: ExposureWindowRiskCalculator(
                    dateProvider: services.currentDateProvider,
                    isolationLength: isolationLength,
                    submitExposureWindows: { windowInfo in
                        let postcode = getPostcode()?.value ?? ""
                        exposureWindowAnalyticsHandler.post(windowInfo: windowInfo, latestAppVersion: services.appInfo.version, postcode: postcode, client: services.apiClient)
                        trafficObfuscationClient.sendTraffic(for: TrafficObfuscator.exposureWindow, randomRange: 2 ... 15, numberOfActualCalls: windowInfo.count)
                    }
                )
            )
            exposureWindowStore = ExposureWindowStore(store: services.encryptedStore)
        } else {
            exposureWindowAnalyticsHandler = nil
            exposureRiskManager = ExposureRiskManager(controller: controller)
            exposureWindowStore = nil
        }
        
        exposureKeysManager = ExposureKeysManager(
            controller: controller,
            submissionClient: services.apiClient
        )
        
        exposureDetectionManager = ExposureDetectionManager(
            controller: controller,
            distributionClient: services.distributeClient,
            fileStorage: services.cacheStorage,
            encryptedStore: services.encryptedStore,
            interestedInExposureNotifications: interestedInExposureNotifications,
            exposureRiskManager: exposureRiskManager
        )
        
        diagnosisKeyCacheHouskeeper = DiagnosisKeyCacheHousekeeper(
            fileStorage: services.cacheStorage,
            exposureDetectionStore: exposureDetectionStore,
            currentDateProvider: services.currentDateProvider
        )
        
        // Used for EN v1 only:
        // Show the "Don't worry" notification if the EN API returns an exposure but our own logic does not consider
        // it as risky (and therefore does not send the user to isolation)
        handleDontWorryNotification = {
            services.userNotificationsManager.add(type: .exposureDontWorry, at: nil, withCompletionHandler: nil)
        }
        
        exposureNotificationStateController = ExposureNotificationStateController(manager: exposureNotificationManager)
        exposureNotificationStateController.activate()
    }
    
    func detectExposures(deferShouldShowDontWorryNotification: @escaping () -> Void) -> AnyPublisher<Void, Never> {
        diagnosisKeyCacheHouskeeper.deleteFilesOlderThanADay()
            .append(
                _detectExposures(deferShouldShowDontWorryNotification: deferShouldShowDontWorryNotification)
            )
            .append(Deferred(createPublisher: diagnosisKeyCacheHouskeeper.deleteNotNeededFiles))
            .eraseToAnyPublisher()
    }
    
    private func _detectExposures(deferShouldShowDontWorryNotification: @escaping () -> Void) -> AnyPublisher<Void, Never> {
        if #available(iOS 13.7, *) {
            return detectExposuresV2()
        } else {
            return detectExposuresV1(deferShouldShowDontWorryNotification: deferShouldShowDontWorryNotification)
        }
    }
    
    @available(iOS 13.7, *)
    private func detectExposuresV2() -> AnyPublisher<Void, Never> {
        exposureDetectionManager.detectExposures(
            currentDate: currentDateProvider.currentDate,
            sendFakeExposureWindows: {
                trafficObfuscationClient.sendTraffic(for: .exposureWindow, randomRange: 2 ... 15, numberOfActualCalls: 0)
            }
        )
        .filterNil()
        .map { riskInfo in
            _ = exposureDetectionStore.saveIfNeeded(exposureRiskInfo: riskInfo)
        }
        .eraseToAnyPublisher()
    }
    
    private func detectExposuresV1(deferShouldShowDontWorryNotification: @escaping () -> Void) -> AnyPublisher<Void, Never> {
        exposureDetectionManager.detectExposures(currentDate: currentDateProvider.currentDate, sendFakeExposureWindows: {})
            .filterNil()
            .map { riskInfo in
                let riskHandled = exposureDetectionStore.saveIfNeeded(exposureRiskInfo: riskInfo)
                if !riskHandled, riskInfo.shouldShowDontWorryNotification {
                    handleDontWorryNotification()
                } else {
                    deferShouldShowDontWorryNotification()
                }
            }
            .eraseToAnyPublisher()
    }
    
}

class ExposureWindowAnalyticsHandler {
    
    var cancellables = [AnyCancellable]()
    
    @available(iOS 13.7, *)
    func post(windowInfo: [(ExposureNotificationExposureWindow, ExposureRiskInfo)], latestAppVersion: Version, postcode: String, client: HTTPClient) {
        windowInfo.forEach { window, riskInfo in
            let endpoint = ExposureWindowEventEndpoint(riskInfo: riskInfo, latestAppVersion: latestAppVersion, postcode: postcode, hasPositiveTest: false)
            client.fetch(endpoint, with: window)
                .ensureFinishes(placeholder: ())
                .sink { _ in }
                .store(in: &cancellables)
        }
    }
}
