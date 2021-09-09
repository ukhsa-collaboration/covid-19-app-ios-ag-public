//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation

extension Array where Element == ExposureWindowInfo {
    var riskyWindows: [Element] {
        filter { $0.isConsideredRisky }
    }
    
    var nonRiskyWindows: [Element] {
        filter { !$0.isConsideredRisky }
    }
}

extension ExposureWindowInfo {
    static let nonRiskyWindowSendLimit = 15
    static let nonRiskyWindowStoreLimit = 15
}

struct ExposureNotificationContext {
    var exposureNotificationStateController: ExposureNotificationStateController
    var exposureNotificationManager: ExposureNotificationManaging
    var exposureDetectionStore: ExposureDetectionStore
    var exposureDetectionManager: ExposureDetectionManager
    var exposureKeysManager: ExposureKeysManager
    var diagnosisKeyCacheHousekeeper: DiagnosisKeyCacheHousekeeper
    var handleDontWorryNotification: () -> Void
    var exposureWindowAnalyticsHandler: ExposureWindowAnalyticsHandler?
    var currentDateProvider: DateProviding
    var exposureWindowStore: ExposureWindowStore?
    var trafficObfuscationClient: TrafficObfuscationClient
    
    private var userNotificationManager: UserNotificationManaging
    
    static let exposureWindowExpiryDays = 14
    
    var isWaitingForApproval: Bool {
        exposureDetectionStore.exposureInfo?.approvalToken != nil
    }
    
    init(
        services: ApplicationServices,
        isolationLength: DayDuration,
        interestedInExposureNotifications: @escaping () -> Bool,
        getPostcode: @escaping () -> Postcode?,
        getLocalAuthority: @escaping () -> LocalAuthorityId?
    ) {
        exposureNotificationManager = services.exposureNotificationManager
        currentDateProvider = services.currentDateProvider
        userNotificationManager = services.userNotificationsManager
        
        exposureDetectionStore = ExposureDetectionStore(store: services.encryptedStore)
        let controller = ExposureNotificationDetectionController(manager: services.exposureNotificationManager)
        
        self.trafficObfuscationClient = TrafficObfuscationClient(client: services.apiClient, rateLimiter: ObfuscationRateLimiter())
        let trafficObfuscationClient = self.trafficObfuscationClient
        
        let exposureRiskManager: ExposureRiskManaging
        if #available(iOS 13.7, *) {
            let exposureWindowAnalyticsHandler = ExposureWindowAnalyticsHandler(
                latestAppVersion: services.appInfo.version,
                getPostcode: getPostcode,
                getLocalAuthority: getLocalAuthority,
                client: services.apiClient
            )
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
                        exposureWindowAnalyticsHandler.post(windowInfo: Self.windowsToSend(infos), eventType: .exposureWindow)
                        trafficObfuscationClient.sendTraffic(for: TrafficObfuscator.exposureWindow, randomRange: 2 ... 15, numberOfActualCalls: Self.windowsToSend(infos).count)
                        
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
            submissionClient: services.apiClient,
            trafficObfuscationClient: trafficObfuscationClient,
            contactCaseIsolationDuration: isolationLength,
            currentDateProvider: currentDateProvider
        )
        
        exposureDetectionManager = ExposureDetectionManager(
            controller: controller,
            distributionClient: services.distributeClient,
            fileStorage: services.cacheStorage,
            encryptedStore: services.encryptedStore,
            interestedInExposureNotifications: interestedInExposureNotifications,
            exposureRiskManager: exposureRiskManager
        )
        
        diagnosisKeyCacheHousekeeper = DiagnosisKeyCacheHousekeeper(
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
    
    static func windowsToSend(
        _ windows: [ExposureWindowInfo],
        limit: Int = ExposureWindowInfo.nonRiskyWindowSendLimit
    ) -> [ExposureWindowInfo] {
        windows.riskyWindows + windows.nonRiskyWindows.suffix(limit)
    }
    
    func detectExposures(deferShouldShowDontWorryNotification: @escaping () -> Void) -> AnyPublisher<Void, Never> {
        return diagnosisKeyCacheHousekeeper.deleteFilesOlderThanADay()
            .append(
                _detectExposures(deferShouldShowDontWorryNotification: deferShouldShowDontWorryNotification)
            )
            .append(Deferred(createPublisher: diagnosisKeyCacheHousekeeper.deleteNotNeededFiles))
            .eraseToAnyPublisher()
    }
    
    func calculateExpiredWindowsDay(_ relativeTo: Date, offset: Int) -> GregorianDay {
        let expiredDate = GregorianDay(date: relativeTo, timeZone: .current).advanced(by: offset)
        return expiredDate
    }
    
    var expiredWindowsDay: GregorianDay {
        return calculateExpiredWindowsDay(currentDateProvider.currentDate, offset: -Self.exposureWindowExpiryDays)
    }
    
    func deleteExpiredExposureWindows() {
        guard let exposureWindowStore = exposureWindowStore else {
            return
        }
        
        exposureWindowStore.deleteWindows(includingAndPriorTo: expiredWindowsDay)
    }
    
    func postExposureWindows(result: UnacknowledgedTestResult, testKitType: TestKitType?, requiresConfirmatoryTest: Bool) {
        guard #available(iOS 13.7, *),
            let exposureWindowStore = exposureWindowStore,
            let exposureWindowAnalyticsHandler = exposureWindowAnalyticsHandler else { return }
        
        let exposureWindowInfoCollection = exposureWindowStore.load()
        
        if let exposureWindowInfoCollection = exposureWindowInfoCollection, result == .positive {
            
            exposureWindowAnalyticsHandler.post(windowInfo: exposureWindowInfoCollection.exposureWindowsInfo, eventType: .exposureWindowPositiveTest(testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest))
            trafficObfuscationClient.sendTraffic(for: .exposureWindowAfterPositive, randomRange: 2 ... 15, numberOfActualCalls: exposureWindowInfoCollection.exposureWindowsInfo.count)
        } else {
            trafficObfuscationClient.sendTraffic(for: .exposureWindowAfterPositive, randomRange: 2 ... 15, numberOfActualCalls: 0)
        }
    }
    
    func resendExposureDetectionNotificationIfNeeded(isolationContext: IsolationContext) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            let isolation = isolationContext.isolationStateManager.isolationLogicalState.currentValue
            let startAcknowledged = isolationContext.isolationStateStore.isolationInfo.hasAcknowledgedStartOfContactIsolation
            if isolation.isIsolating, isolation.activeIsolation?.isContactCaseOnly ?? false, !startAcknowledged {
                userNotificationManager.add(type: .exposureDetection, at: nil, withCompletionHandler: nil)
                Metrics.signpost(.totalRiskyContactReminderNotifications)
            }
            
            promise(.success(()))
        }.eraseToAnyPublisher()
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
    private var getLocalAuthority: () -> LocalAuthorityId?
    private var client: HTTPClient
    
    var cancellables = [AnyCancellable]()
    
    init(latestAppVersion: Version,
         getPostcode: @escaping () -> Postcode?,
         getLocalAuthority: @escaping () -> LocalAuthorityId?,
         client: HTTPClient) {
        self.latestAppVersion = latestAppVersion
        self.getPostcode = getPostcode
        self.getLocalAuthority = getLocalAuthority
        self.client = client
    }
    
    @available(iOS 13.7, *)
    func post(windowInfo: [ExposureWindowInfo], eventType: EpidemiologicalEventType) {
        let postcode = getPostcode()?.value ?? ""
        let localAuthority = getLocalAuthority()?.value ?? ""
        
        windowInfo.forEach { exposureWindowInfo in
            let endpoint = ExposureWindowEventEndpoint(
                latestAppVersion: latestAppVersion,
                postcode: postcode,
                localAuthority: localAuthority,
                eventType: eventType
            )
            
            client.fetch(endpoint, with: exposureWindowInfo)
                .ensureFinishes(placeholder: ())
                .sink { _ in }
                .store(in: &cancellables)
        }
    }
}
