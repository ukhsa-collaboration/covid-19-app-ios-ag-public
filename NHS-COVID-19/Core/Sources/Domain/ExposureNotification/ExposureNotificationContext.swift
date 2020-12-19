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
    
    var isWaitingForApproval: Bool {
        exposureDetectionStore.exposureInfo?.approvalToken != nil
    }
    
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
        
        self.trafficObfuscationClient = TrafficObfuscationClient(client: services.apiClient)
        let trafficObfuscationClient = self.trafficObfuscationClient
        
        let exposureRiskManager: ExposureRiskManaging
        if #available(iOS 13.7, *) {
            let exposureWindowAnalyticsHandler = ExposureWindowAnalyticsHandler(latestAppVersion: services.appInfo.version, getPostcode: getPostcode, client: services.apiClient)
            self.exposureWindowAnalyticsHandler = exposureWindowAnalyticsHandler
            
            let exposureWindowStore = ExposureWindowStore(store: services.encryptedStore)
            self.exposureWindowStore = exposureWindowStore
            exposureRiskManager = ExposureWindowRiskManager(
                controller: controller,
                riskCalculator: ExposureWindowRiskCalculator(
                    dateProvider: services.currentDateProvider,
                    isolationLength: isolationLength,
                    submitExposureWindows: { windowInfo in
                        let infos = windowInfo.map {
                            ExposureWindowInfo(exposureWindow: $0.0, riskInfo: $0.1)
                        }
                        exposureWindowAnalyticsHandler.post(windowInfo: infos, hasPositiveTest: false)
                        trafficObfuscationClient.sendTraffic(for: TrafficObfuscator.exposureWindow, randomRange: 2 ... 15, numberOfActualCalls: infos.count)
                        exposureWindowStore.append(infos)
                    }
                )
            )
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
        return diagnosisKeyCacheHouskeeper.deleteFilesOlderThanADay()
            .append(
                _detectExposures(deferShouldShowDontWorryNotification: deferShouldShowDontWorryNotification)
            )
            .append(Deferred(createPublisher: diagnosisKeyCacheHouskeeper.deleteNotNeededFiles))
            .eraseToAnyPublisher()
    }
    
    func deleteExposureWindows() {
        guard let exposureWindowStore = exposureWindowStore else {
            return
        }
        
        exposureWindowStore.delete()
    }
    
    func postExposureWindows(result: TestResult) {
        guard #available(iOS 13.7, *),
            let exposureWindowStore = exposureWindowStore,
            let exposureWindowAnalyticsHandler = exposureWindowAnalyticsHandler else { return }
        
        let exposureWindowInfoCollection = exposureWindowStore.load()
        
        if let exposureWindowInfoCollection = exposureWindowInfoCollection, result == .positive {
            exposureWindowAnalyticsHandler.post(windowInfo: exposureWindowInfoCollection.exposureWindowsInfo, hasPositiveTest: true)
            trafficObfuscationClient.sendTraffic(for: .exposureWindowAfterPositive, randomRange: 2 ... 15, numberOfActualCalls: exposureWindowInfoCollection.exposureWindowsInfo.count)
        } else {
            trafficObfuscationClient.sendTraffic(for: .exposureWindowAfterPositive, randomRange: 2 ... 15, numberOfActualCalls: 0)
        }
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
    private var latestAppVersion: Version
    private var getPostcode: () -> Postcode?
    private var client: HTTPClient
    
    var cancellables = [AnyCancellable]()
    
    init(latestAppVersion: Version, getPostcode: @escaping () -> Postcode?, client: HTTPClient) {
        self.latestAppVersion = latestAppVersion
        self.getPostcode = getPostcode
        self.client = client
    }
    
    @available(iOS 13.7, *)
    func post(windowInfo: [ExposureWindowInfo], hasPositiveTest: Bool) {
        let postcode = getPostcode()?.value ?? ""
        
        windowInfo.forEach { exposureWindowInfo in
            let endpoint = ExposureWindowEventEndpoint(latestAppVersion: latestAppVersion, postcode: postcode, hasPositiveTest: hasPositiveTest)
            client.fetch(endpoint, with: exposureWindowInfo)
                .ensureFinishes(placeholder: ())
                .sink { _ in }
                .store(in: &cancellables)
        }
    }
    
}
