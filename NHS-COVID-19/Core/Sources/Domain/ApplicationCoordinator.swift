//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import Logging
import RiskScore
import UIKit

public class ApplicationCoordinator {
    
    private static let latestPolicyAppVersion = "4.16"
    
    private static let logger = Logger(label: "ApplicationCoordinator")
    
    private let application: Application
    private let appAvailabilityManager: AppAvailabilityManager
    private let metricReporter: MetricReporter
    private let userNotificationsStateController: UserNotificationsStateController
    private var cancellables = [AnyCancellable]()
    private let processingTaskRequestManager: ProcessingTaskRequestManaging
    private var backgroundTaskAggregator: BackgroundTaskAggregator?
    private let postcodeStore: PostcodeStore
    private let distributeClient: HTTPClient
    private let selfDiagnosisManager: SelfDiagnosisManager
    private let symptomsCheckerManager: SymptomsCheckerManager
    private let exposureNotificationContext: ExposureNotificationContext
    private let checkInContext: CheckInContext
    private let isolationContext: IsolationContext
    
    private let riskyPostcodeEndpointManager: RiskyPostcodeEndpointManager
    private let postcodeInfo: DomainProperty<(postcode: Postcode, localAuthority: LocalAuthority?, risk: DomainProperty<RiskyPostcodeEndpointManager.PostcodeRisk?>)?>
    
    private let localInformationEndpointManager: LocalInformationEndpointManager
    private let localInformation: DomainProperty<LocalInformationEndpointManager.LocalInfo?>
    
    private let notificationCenter: NotificationCenter
    private let virologyTestingManager: VirologyTestingManager
    private let virologyTestingStateStore: VirologyTestingStateStore
    private let keySharingStore: KeySharingStore
    private let circuitBreaker: CircuitBreaker
    private let isolationHousekeeper: IsolationHousekeeper
    private let riskyVenueHousekeeper: RiskyVenueHousekeeper
    private let symptomsCheckerHousekeeper: SymptomsCheckerHousekeeper
    private let exposureNotificationReminder: ExposureNotificationReminder
    private let completedOnboardingForCurrentSession = CurrentValueSubject<Bool, Never>(false)
    private let appReviewPresenter: AppReviewPresenting
    public let country: DomainProperty<Country>
    private let shouldRecommendUpdate = CurrentValueSubject<Bool, Never>(true)
    private let policyManager: PolicyVersionManager
    private let localAuthorityManager: LocalAuthorityManager
    private let isolationPaymentContext: IsolationPaymentContext
    private let trafficObfuscationClient: TrafficObfuscationClient
    private let userNotificationManager: UserNotificationManaging
    private let diagnosisKeySharer: DomainProperty<DiagnosisKeySharer?>
    public let bluetoothOffAcknowledged = CurrentValueSubject<Bool, Never>(false)
    private let localCovidStatsManager: LocalCovidStatsManaging
    
    private var recommendedUpdateManager: RecommendedUpdateManager?
    
    private var isFeatureEnabled: (Feature) -> Bool
    
    @Published
    public var state = ApplicationState.starting
    
    private var currentDateProvider: DateProviding
    private var languageStore: LanguageStore
    private let homeAnimationsStore: HomeAnimationsEnabledProtocol
    
    public let localeConfiguration: DomainProperty<LocaleConfiguration>
    private let keySharingContext: KeySharingContext
    
    public init(services: ApplicationServices, enabledFeatures: [Feature]) {
        application = services.application
        notificationCenter = services.notificationCenter
        processingTaskRequestManager = services.processingTaskRequestManager
        distributeClient = services.distributeClient
        currentDateProvider = services.currentDateProvider
        userNotificationManager = services.userNotificationsManager
        let dateProvider = services.currentDateProvider
        Self.logger.debug("Initialising")
        
        languageStore = LanguageStore(store: services.encryptedStore)
        localeConfiguration = languageStore.languageInfo.map { $0.configuration() }
        homeAnimationsStore = HomeAnimationsStore(store: services.encryptedStore)
        
        appAvailabilityManager = AppAvailabilityManager(
            distributeClient: distributeClient,
            iTunesClient: services.iTunesClient,
            cacheStorage: services.cacheStorage,
            appInfo: services.appInfo
        )
        
        let postcodeStore = PostcodeStore(store: services.encryptedStore)
        
        let localAuthorityValidator = LocalAuthoritiesValidator()
        
        let localAuthority = postcodeStore.localAuthorityId.map { localAuthorityId -> LocalAuthority? in
            guard let localAuthorityId = localAuthorityId else { return nil }
            return localAuthorityValidator.localAuthority(with: localAuthorityId)
        }
        
        let riskyPostcodeEndpointManager = RiskyPostcodeEndpointManager(
            distributeClient: distributeClient,
            storage: services.cacheStorage,
            postcode: postcodeStore.postcode.eraseToAnyPublisher(),
            localAuthority: localAuthority.eraseToAnyPublisher(),
            currentDateProvider: currentDateProvider,
            minimumUpdateIntervalProvider: services.riskyPostcodeUpdateIntervalProvider
        )
        
        postcodeInfo = riskyPostcodeEndpointManager.postcodeInfo
        
        self.riskyPostcodeEndpointManager = riskyPostcodeEndpointManager
        self.postcodeStore = postcodeStore
        
        let localInformationEndpointManager = LocalInformationEndpointManager(
            distributeClient: distributeClient,
            storage: services.cacheStorage,
            encryptedStorage: services.encryptedStore,
            localAuthority: localAuthority.eraseToAnyPublisher(),
            currentDateProvider: currentDateProvider
        )
        
        localInformation = localInformationEndpointManager.localInformation
        self.localInformationEndpointManager = localInformationEndpointManager
        
        let localAuthorityManager = LocalAuthorityManager(
            localAuthoritiesValidator: localAuthorityValidator,
            postcodeStore: postcodeStore
        )
        
        let country = localAuthorityManager.$country.domainProperty()
        self.localAuthorityManager = localAuthorityManager
        self.country = country
        
        isolationContext = IsolationContext(
            isolationConfiguration: CachedResponse(
                httpClient: distributeClient,
                endpoint: IsolationConfigurationEndpoint(),
                storage: services.cacheStorage,
                name: "isolation_configuration",
                initialValue: .default
            ),
            encryptedStore: services.encryptedStore,
            notificationCenter: notificationCenter,
            currentDateProvider: currentDateProvider,
            removeExposureDetectionNotifications: {
                services.userNotificationsManager.removeAllDelivered(for: .exposureDetection)
            },
            country: country
        )
        let isolationContext = self.isolationContext
        
        selfDiagnosisManager = SelfDiagnosisManager(
            httpClient: distributeClient,
            calculateIsolationState: isolationContext.handleSymptomsIsolationState,
            shouldShowNewNoSymptomsScreen: { enabledFeatures.contains(.newNoSymptomsScreen) }
        )
        
        let symptomsCheckerStore = SymptomsCheckerStore(store: services.encryptedStore)
        
        symptomsCheckerManager = SymptomsCheckerManager(
            symptomsCheckerStore: symptomsCheckerStore,
            currentDateProvider: currentDateProvider,
            httpClient: distributeClient
        )
        
        localCovidStatsManager = LocalCovidStatsManager(
            httpClient: distributeClient
        )
        
        let riskyVenueConfiguration = CachedResponse(
            httpClient: distributeClient,
            endpoint: RiskyVenuesConfigurationEndpoint(),
            storage: services.cacheStorage,
            name: "risky_venue_configuration",
            initialValue: .default
        )
        
        let checkInsStore = CheckInsStore(
            store: services.encryptedStore,
            venueDecoder: services.venueDecoder,
            getCachedRiskyVenueConfiguration: { riskyVenueConfiguration.value }
        )
        let checkInsManager = CheckInsManager(
            checkInsStore: checkInsStore,
            httpClient: distributeClient
        )
        checkInContext = CheckInContext(
            checkInsStore: checkInsStore,
            checkInsManager: checkInsManager,
            qrCodeScanner: QRCodeScanner(
                cameraManager: services.cameraManager,
                cameraStateController: CameraStateController(
                    manager: services.cameraManager,
                    notificationCenter: notificationCenter
                )
            ),
            currentDateProvider: currentDateProvider,
            riskyVenueConfiguration: riskyVenueConfiguration
        )
        
        virologyTestingStateStore = VirologyTestingStateStore(
            store: services.encryptedStore,
            dateProvider: dateProvider
        )
        virologyTestingManager = VirologyTestingManager(
            httpClient: services.apiClient,
            virologyTestingStateCoordinator: VirologyTestingStateCoordinator(
                virologyTestingStateStore: virologyTestingStateStore,
                userNotificationsManager: services.userNotificationsManager,
                isInterestedInAskingForSymptomsOnsetDay: { (isolationContext.isolationStateStore.isolationInfo.indexCaseInfo?.isInterestedInAskingForSymptomsOnsetDay ?? true)
                },
                setRequiresOnsetDay: {
                    isolationContext.shouldAskForSymptoms.send(true)
                    Metrics.signpost(.didAskForSymptomsOnPositiveTestEntry)
                },
                country: { country.currentValue }
            ),
            ctaTokenValidator: CTATokenValidator(),
            country: { country.currentValue }
        )
        
        let isolationStateManager = isolationContext.isolationStateManager
        
        let interestedInExposureNotifications = { isolationStateManager.state.interestedInExposureNotifications }
        
        let exposureNotificationProcessingBehaviour = { isolationStateManager.state.exposureNotificationProcessingBehaviour }
        
        isolationPaymentContext = IsolationPaymentContext(
            services: services,
            country: country,
            isolationState: isolationStateManager.$state.domainProperty(),
            isolationStateStore: isolationContext.isolationStateStore
        )
        
        let keySharingStore = KeySharingStore(store: services.encryptedStore)
        self.keySharingStore = keySharingStore
        
        #warning("Should be using whatever the most recent isolationConfiguration's value for contact case isolation, not the value at the time of initialisation.")
        exposureNotificationContext = ExposureNotificationContext(
            services: services,
            isolationLength: isolationContext.isolationConfiguration.value.for(country.currentValue).contactCase,
            interestedInExposureNotifications: interestedInExposureNotifications,
            getPostcode: { postcodeStore.postcode.currentValue },
            getLocalAuthority: { postcodeStore.localAuthorityId.currentValue }
        )
        
        diagnosisKeySharer = isolationContext.isolationStateStore.$isolationStateInfo
            .map { [exposureNotificationContext, keySharingStore, currentDateProvider] state -> DomainProperty<DiagnosisKeySharer?> in
                guard let indexCaseInfo = state?.isolationInfo.indexCaseInfo else {
                    return .constant(nil)
                }
                
                return exposureNotificationContext.exposureKeysManager.makeDiagnosisKeySharer(
                    assumedOnsetDay: indexCaseInfo.assumedOnsetDayForExposureKeys,
                    currentDateProvider: currentDateProvider,
                    keySharingInfo: keySharingStore.info,
                    completionHandler: { result in
                        switch result {
                        case .markInitialFlowComplete:
                            keySharingStore.didFinishInitialKeySharingFlow()
                        case .markToDelete:
                            keySharingStore.reset()
                        }
                    }
                )
            }.switchToLatest().domainProperty()
        
        userNotificationsStateController = UserNotificationsStateController(
            manager: services.userNotificationsManager,
            notificationCenter: notificationCenter
        )
        
        metricReporter = MetricReporter(
            client: services.apiClient,
            encryptedStore: services.encryptedStore,
            currentDateProvider: currentDateProvider,
            appInfo: services.appInfo,
            getPostcode: { postcodeStore.postcode.currentValue?.value },
            getLocalAuthority: { postcodeStore.localAuthorityId.currentValue?.value },
            getHouseKeepingDayDuration: { isolationContext.isolationStateStore.configuration.housekeepingDeletionPeriod },
            isFeatureEnabled: { enabledFeatures.contains($0) },
            getCountry: { country.currentValue }
        )
        
        #warning("Should be using whatever the most recent isolationConfiguration's value for contact case isolation, not the value at the time of initialisation.")
        circuitBreaker = CircuitBreaker(
            client: CircuitBreakerClient(httpClient: services.apiClient, rateLimiter: ObfuscationRateLimiter()),
            exposureInfoProvider: exposureNotificationContext.exposureDetectionStore,
            riskyCheckinsProvider: checkInContext.checkInsStore,
            currentDateProvider: dateProvider,
            contactCaseIsolationDuration: isolationContext.isolationConfiguration.value.for(country.currentValue).contactCase,
            handleContactCase: { riskInfo in
                isolationContext.handleContactCase(riskInfo: riskInfo, sendContactCaseIsolationNotification: {
                    services.userNotificationsManager.removePending(type: .exposureDontWorry)
                    services.userNotificationsManager.add(type: .exposureDetection, at: nil, withCompletionHandler: nil)
                })
            },
            handleDontWorryNotification: exposureNotificationContext.handleDontWorryNotification,
            exposureNotificationProcessingBehaviour: exposureNotificationProcessingBehaviour
        )
        
        isolationHousekeeper = IsolationHousekeeper(
            isolationStateStore: isolationContext.isolationStateStore,
            isolationStateManager: isolationStateManager,
            virologyTestingStateStore: virologyTestingStateStore,
            getToday: { dateProvider.currentGregorianDay(timeZone: .current) }
        )
        
        riskyVenueHousekeeper = RiskyVenueHousekeeper(
            checkInsStore: checkInContext.checkInsStore,
            getToday: { dateProvider.currentGregorianDay(timeZone: .current) }
        )
        
        symptomsCheckerHousekeeper = SymptomsCheckerHousekeeper(
            symptomsCheckerStore: symptomsCheckerManager.symptomsCheckerStore,
            getToday: { dateProvider.currentGregorianDay(timeZone: .current) }
        )
        
        #warning("Should be using whatever the most recent isolationConfiguration's value for contact case isolation, not the value at the time of initialisation.")
        keySharingContext = KeySharingContext(
            currentDateProvider: currentDateProvider,
            contactCaseIsolationDuration: self.isolationContext.isolationConfiguration.value.for(country.currentValue).contactCase,
            onsetDay: { [isolationContext] in
                isolationContext.isolationStateStore.isolationInfo.indexCaseInfo?.assumedOnsetDayForExposureKeys
            },
            keySharingStore: keySharingStore,
            userNotificationManager: services.userNotificationsManager
        )
        
        exposureNotificationReminder = ExposureNotificationReminder(
            userNotificationManager: services.userNotificationsManager,
            userNotificationStateController: userNotificationsStateController,
            currentDateProvider: currentDateProvider,
            exposureNotificationEnabled: exposureNotificationContext.exposureNotificationStateController.isEnabledPublisher
        )
        
        appReviewPresenter = AppReviewPresenter(
            checkInsStore: checkInContext.checkInsStore,
            reviewController: services.storeReviewController,
            currentDateProvider: currentDateProvider
        )
        
        policyManager = PolicyVersionManager(
            encryptedStore: services.encryptedStore,
            currentVersion: services.appInfo.version,
            neededVersion: Self.latestPolicyAppVersion
        )
        
        trafficObfuscationClient = TrafficObfuscationClient(client: services.apiClient, rateLimiter: ObfuscationRateLimiter())
        
        isFeatureEnabled = { feature in
            enabledFeatures.contains(feature)
        }
        
        metricReporter.set(rawState: rawState.domainProperty())
        
        monitorRawState()
        
        setupBackgroundTask()
        
        setupChangeNotifiers(
            using: services.userNotificationsManager,
            localAuthority: localAuthority.eraseToAnyPublisher(),
            languageCode: languageStore.languageInfo.map { $0.languageCode }.eraseToAnyPublisher(),
            postcode: postcodeStore.postcode.eraseToAnyPublisher(),
            localAuthorityValidator: localAuthorityValidator
        )
        
        metricReporter.monitorHousekeeping()
        
        services.userNotificationsManager.removePending(type: .selfIsolation)
        
    }
    
    private func monitorRawState() {
        rawState
            .log(into: Self.logger, "raw state changed")
            .map { $0.logicalState }
            .removeDuplicates()
            .log(into: Self.logger, level: .info, "logical state changed")
            .sink { [weak self] logicalState in
                guard let self = self else { return }
                self.state = self.makeState(for: logicalState)
            }
            .store(in: &cancellables)
    }
    
    private func makeState(for logicalState: LogicalState) -> ApplicationState {
        switch logicalState {
        case .starting:
            return .starting
        case .appUnavailable(let logicalReason, let descriptions):
            let reason: ApplicationState.AppUnavailabilityReason
            switch logicalReason {
            case .iOSTooOld:
                reason = .iOSTooOld(descriptions: descriptions)
            case .appTooOld(let updateAvailable):
                reason = .appTooOld(updateAvailable: updateAvailable, descriptions: descriptions)
            }
            return .appUnavailable(reason)
        case .failedToStart:
            return .failedToStart(openURL: application.open)
        case .onboarding:
            let completedOnboardingForCurrentSession = self.completedOnboardingForCurrentSession
            return .onboarding(
                complete: { [weak self] in
                    self?.policyManager.acceptWithCurrentAppVersion()
                    completedOnboardingForCurrentSession.value = true
                },
                openURL: application.open,
                isFeatureEnabled: isFeatureEnabled
            )
        case .authorizationRequired:
            return .authorizationRequired(
                requestPermissions: requestPermissions,
                country: country
            )
        case .canNotRunExposureNotification(let reason):
            return .canNotRunExposureNotification(reason: disabledReason(from: reason), country: country.currentValue)
        case .postcodeAndLocalAuthorityRequired:
            return .postcodeAndLocalAuthorityRequired(openURL: application.open, getLocalAuthorities: localAuthorityManager.localAuthorities, storeLocalAuthority: localAuthorityManager.store)
        case .localAuthorityRequired:
            if let postcode = postcodeStore.postcode.currentValue {
                let result = localAuthorityManager.localAuthorities(for: postcode)
                if case .success(let localAuthorities) = result {
                    return .localAuthorityRequired(postcode: postcode, localAuthorities: localAuthorities, openURL: application.open, storeLocalAuthority: localAuthorityManager.store)
                } else {
                    return .postcodeAndLocalAuthorityRequired(openURL: application.open, getLocalAuthorities: localAuthorityManager.localAuthorities, storeLocalAuthority: localAuthorityManager.store)
                }
            }
            #warning("What should be done if this happens?")
            preconditionFailure("This constellation should never happen")
        case .fullyOnboarded:
            let bluetoothOff = exposureNotificationContext.exposureNotificationManager.exposureNotificationStatusPublisher.map { $0 == .bluetoothOff }.eraseToAnyPublisher()
            let bluetoothOffAcknowledgementNeeded = bluetoothOffAcknowledged.combineLatest(bluetoothOff).map { acknowledged, bluetoothOff -> Bool in
                if acknowledged { return false }
                else if bluetoothOff { return true }
                else { return false }
            }.eraseToAnyPublisher()
            let country = self.country
            
            let isolationStateStore = isolationContext.isolationStateStore
            #warning("For `contactCaseIsolationDuration`: Should be using whatever the most recent isolationConfiguration's value for contact case isolation, not the value at the time of initialisation.")
            return .runningExposureNotification(
                RunningAppContext(
                    checkInContext: checkInContext,
                    shouldShowVenueCheckIn: isFeatureEnabled(.venueCheckIn),
                    shouldShowTestingForCOVID19: isFeatureEnabled(.testingForCOVID19),
                    shouldShowSelfIsolationHubEngland: isFeatureEnabled(.selfIsolationHubEngland),
                    shouldShowSelfIsolationHubWales: isFeatureEnabled(.selfIsolationHubWales),
                    shouldShowEnglandOptOutFlow: isFeatureEnabled(.contactOptOutFlowEngland),
                    shouldShowWalesOptOutFlow: isFeatureEnabled(.contactOptOutFlowWales),
                    shouldShowGuidanceHubEngland: isFeatureEnabled(.guidanceHubEngland),
                    shouldShowGuidanceHubWales: isFeatureEnabled(.guidanceHubWales),
                    postcodeInfo: postcodeInfo,
                    country: country,
                    bluetoothOff: bluetoothOff.domainProperty(),
                    bluetoothOffAcknowledgementNeeded: bluetoothOffAcknowledgementNeeded,
                    bluetoothOffAcknowledgedCallback: { [weak self] in
                        self?.bluetoothOffAcknowledged.send(true)
                    },
                    openSettings: application.openSettings,
                    openAppStore: application.openAppStore,
                    openURL: application.open,
                    selfDiagnosisManager: selfDiagnosisManager,
                    symptomsCheckerManager: symptomsCheckerManager,
                    isolationState: isolationContext.isolationStateManager.$state
                        .map(IsolationState.init)
                        .domainProperty(),
                    testInfo: isolationStateStore.$isolationStateInfo.map { $0?.isolationInfo.indexCaseInfo?.testInfo }.domainProperty(),
                    isolationAcknowledgementState: isolationContext.makeIsolationAcknowledgementState(),
                    exposureNotificationStateController: exposureNotificationContext.exposureNotificationStateController,
                    virologyTestingManager: virologyTestingManager,
                    testResultAcknowledgementState: makeTestResultAcknowledgementState(),
                    symptomsOnsetAndExposureDetailsProvider: isolationStateStore,
                    deleteAllData: { [weak self] in
                        self?.deleteAllData()
                    },
                    deleteCheckIn: { [weak self] id in
                        self?.deleteCheckIn(with: id)
                    },
                    riskyCheckInsAcknowledgementState: makeRiskyCheckInsAcknowledgementState(),
                    currentDateProvider: currentDateProvider,
                    exposureNotificationReminder: exposureNotificationReminder,
                    appReviewPresenter: appReviewPresenter,
                    getLocalAuthorities: localAuthorityManager.localAuthorities,
                    storeLocalAuthorities: { postcode, localAuthority in
                        let result = self.localAuthorityManager.store(postcode: postcode, localAuthority: localAuthority)
                        if case .success = result {
                            self.riskyPostcodeEndpointManager.reload()
                        }
                        return result
                    },
                    isolationPaymentState: isolationPaymentContext.isolationPaymentState,
                    currentLocaleConfiguration: languageStore.languageInfo.map { $0.configuration() },
                    storeNewLanguage: languageStore.save,
                    homeAnimationsStore: homeAnimationsStore,
                    diagnosisKeySharer: diagnosisKeySharer,
                    localInformation: localInformation,
                    userNotificationManaging: userNotificationManager,
                    shouldShowBookALabTest: isolationContext.canBookALabTest().domainProperty(),
                    contactCaseOptOutQuestionnaire: ContactCaseOptOutQuestionnaire(country: country),
                    contactCaseIsolationDuration: isolationContext.isolationConfiguration.$value.map { $0.for(country.currentValue).contactCase }.domainProperty(),
                    shouldShowLocalStats: isFeatureEnabled(.localStatistics),
                    localCovidStatsManager: localCovidStatsManager
                )
            )
        case .recommendingUpdate(let reason, let titles, let descriptions):
            recommendedUpdateManager = RecommendedUpdateManager(notificationCenter: notificationCenter, recommendedUpdateAction: { [weak self] in
                self?.shouldRecommendUpdate.value = true
            })
            switch reason {
            case .appOlderThanRecommended:
                return .recommendedUpdate(ApplicationState.RecommendedUpdateReason.newRecommendedAppUpdate(title: titles, descriptions: descriptions, dismissAction: { [weak self] in
                    self?.shouldRecommendUpdate.value = false
                }))
            case .iOSOlderThanRecommended:
                return .recommendedUpdate(ApplicationState.RecommendedUpdateReason.newRecommendedOSupdate(title: titles, descriptions: descriptions, dismissAction: { [weak self] in
                    self?.shouldRecommendUpdate.value = false
                    
                }))
            }
        case .policyAcceptanceRequired:
            return .policyAcceptanceRequired(
                saveCurrentVersion: policyManager.acceptWithCurrentAppVersion,
                openURL: application.open
            )
        }
    }
    
    private func makeRiskyCheckInsAcknowledgementState() -> AnyPublisher<RiskyCheckInsAcknowledgementState, Never> {
        let checkInContext = self.checkInContext
        
        return checkInContext.checkInsStore.$mostRecentAndSevereUnacknowledgedRiskyCheckIn
            .removeDuplicates()
            .map { lastRiskyCheckIn in
                if let lastRiskyCheckIn = lastRiskyCheckIn {
                    return .needed(
                        acknowledge: checkInContext.checkInsStore.acknowldegeRiskyCheckIns,
                        venueName: lastRiskyCheckIn.venueName,
                        checkInDate: lastRiskyCheckIn.checkedIn.date,
                        resolution: RiskyVenueResolution(lastRiskyCheckIn.venueMessageType ?? RiskyVenue.MessageType.warnAndInform)
                    )
                }
                return RiskyCheckInsAcknowledgementState.notNeeded
            }
            .eraseToAnyPublisher()
    }
    
    private func makeTestResultAcknowledgementState() -> AnyPublisher<TestResultAcknowledgementState, Never> {
        virologyTestingStateStore.virologyTestResult
            .combineLatest(virologyTestingStateStore.recievedUnknownTestResult)
            .map { [weak self] virologyTestResult, recievedUnknownTestResult -> AnyPublisher<TestResultAcknowledgementState, Never> in
                
                guard let self = self else {
                    return Just(.notNeeded)
                        .eraseToAnyPublisher()
                }
                
                if virologyTestResult == nil, recievedUnknownTestResult == true {
                    return Just(.neededForUnknownResult(
                        acknowledge: self.virologyTestingManager.acknowledgeUnknownTestResult,
                        openAppStore: self.application.openAppStore
                    )
                    )
                    .eraseToAnyPublisher()
                }
                
                guard let virologyTestResult = virologyTestResult else {
                    return Just(.notNeeded)
                        .eraseToAnyPublisher()
                }
                
                return self.isolationContext.makeResultAcknowledgementState(
                    result: virologyTestResult
                ) { [weak self] completionActions in
                    guard let self = self else { return }
                    
                    if completionActions.shouldSuggestBookingFollowUpTest {
                        self.virologyTestingManager
                            .followUpTestRequired
                            .send(true)
                    }
                    
                    if completionActions.shouldAllowKeySubmission, let diagnosisKeySubmissionToken = virologyTestResult.diagnosisKeySubmissionToken {
                        self.keySharingStore.save(
                            token: diagnosisKeySubmissionToken,
                            acknowledgmentTime: UTCHour(containing: self.currentDateProvider.currentDate)
                        )
                        Metrics.signpost(.askedToShareExposureKeysInTheInitialFlow)
                    } else {
                        self.trafficObfuscationClient.sendSingleTraffic(for: TrafficObfuscator.keySubmission)
                    }
                    
                    self.virologyTestingStateStore.remove(testResult: virologyTestResult)
                    
                    self.exposureNotificationContext.postExposureWindows(
                        result: virologyTestResult.testResult,
                        testKitType: virologyTestResult.testKitType,
                        requiresConfirmatoryTest: virologyTestResult.requiresConfirmatoryTest
                    )
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    private func disabledReason(from logicalReason: LogicalState.ExposureDetectionDisabledReason) -> ApplicationState.ExposureDetectionDisabledReason {
        switch logicalReason {
        case .authorizationDenied:
            return .authorizationDenied(openSettings: application.openSettings)
        }
    }
    
    private var rawState: AnyPublisher<RawState, Never> {
        return appAvailabilityManager.$metadata
            .combineLatest(completedOnboardingForCurrentSession, shouldRecommendUpdate, policyManager.$needsAcceptNewVersion)
            .combineLatest(exposureNotificationContext.exposureNotificationStateController.combinedState, userNotificationsStateController.$authorizationStatus, postcodeStore.state)
            .map { f in
                RawState(
                    appAvailability: f.0.0,
                    completedOnboardingForCurrentSession: f.0.1,
                    exposureState: f.1,
                    userNotificationsStatus: f.2,
                    postcodeState: f.3,
                    shouldRecommendUpdate: f.0.2,
                    shouldShowPolicyUpdate: f.0.3
                )
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private func setupBackgroundTask() {
        $state.sink { [weak self] state in
            guard let self = self else { return }
            self.backgroundTaskAggregator = BackgroundTaskAggregator(
                manager: self.processingTaskRequestManager,
                jobs: self.makeBackgroundJobs(for: state)
            )
            if self.shouldImmediatelyRunBackgroundJobs(in: state) {
                // this starts fetching all the config and state data
                self.backgroundTaskAggregator?.performBackgroundTask(backgroundTask: NoOpBackgroundTask())
            }
            // start checking that we have the latest postcode and local info once we are in an on-boarded state
            if case .runningExposureNotification = state {
                self.riskyPostcodeEndpointManager.monitorRiskyPostcodes()
                self.localInformationEndpointManager.monitorLocalInformation()
            }
        }.store(in: &cancellables)
    }
    
    private func shouldImmediatelyRunBackgroundJobs(in state: ApplicationState) -> Bool {
        switch state {
        case .runningExposureNotification where riskyPostcodeEndpointManager.isEmpty:
            // We’re likely in a state that the app is just onboarded.
            // Run background tasks once to fill up our state.
            return true
        default:
            return false
        }
    }
    
    private func makeBackgroundJobs(for state: ApplicationState) -> [BackgroundTaskAggregator.Job] {
        let availabilityCheck = BackgroundTaskAggregator.Job(
            work: appAvailabilityManager.update
        )
        
        var enabledJobs = [availabilityCheck]
        
        switch state {
        case .runningExposureNotification,
             .policyAcceptanceRequired,
             .localAuthorityRequired,
             .postcodeAndLocalAuthorityRequired where postcodeStore.postcode.currentValue != nil,
             .recommendedUpdate:
            enabledJobs.append(contentsOf: makeBackgroundJobsForRunningState())
        case .appUnavailable,
             .authorizationRequired,
             .canNotRunExposureNotification,
             .failedToStart,
             .onboarding,
             .postcodeAndLocalAuthorityRequired,
             .starting:
            // We're not in a state where we can do background jobs,
            // including exposure detections.
            break
        }
        
        if !state.isAppUnavailable {
            let uploadMetricsJob = BackgroundTaskAggregator.Job { [metricReporter] in
                metricReporter.createHouskeepingPublisher()
                    .append(Deferred(createPublisher: metricReporter.uploadMetrics))
                    .eraseToAnyPublisher()
            }
            
            enabledJobs.append(uploadMetricsJob)
        } else {
            enabledJobs.append(
                BackgroundTaskAggregator.Job(
                    work: metricReporter.createHouskeepingPublisher
                )
            )
        }
        
        return enabledJobs
    }
    
    private func makeBackgroundJobsForRunningState() -> [BackgroundTaskAggregator.Job] {
        var enabledJobs = [BackgroundTaskAggregator.Job]()
        
        let circuitBreaker = self.circuitBreaker
        let isolationPaymentContext = self.isolationPaymentContext
        let exposureNotificationContext = self.exposureNotificationContext
        let isolationContext = self.isolationContext
        let exposureWindowHousekeeper = ExposureWindowHousekeeper(
            deleteExpiredExposureWindows: exposureNotificationContext.deleteExpiredExposureWindows
        )
        let country = self.country
        #warning("Should be using whatever the most recent isolationConfiguration's value for contact case isolation, not the value at the time of initialisation.")
        let virologyTokenHousekeeper = VirologyTokenHousekeeper(
            virologyTestingStateStore: virologyTestingStateStore,
            getTokenDeletionPeriod: {
                isolationContext.isolationConfiguration.value.for(country.currentValue).testResultPollingTokenRetentionPeriod
            },
            getToday: { self.currentDateProvider.currentGregorianDay(timeZone: .current) }
        )
        let expsoureNotificationJob = BackgroundTaskAggregator.Job {
            exposureNotificationContext.detectExposures(
                deferShouldShowDontWorryNotification: {
                    circuitBreaker.showDontWorryNotificationIfNeeded = true
                }
            )
            .append(Deferred(createPublisher: { exposureNotificationContext.resendExposureDetectionNotificationIfNeeded(isolationContext: isolationContext) }))
            .append(Deferred(createPublisher: circuitBreaker.processExposureNotificationApproval))
            .append(Deferred(createPublisher: isolationPaymentContext.processCanApplyForFinancialSupport))
            .append(Deferred(createPublisher: exposureWindowHousekeeper.executeHousekeeping))
            .eraseToAnyPublisher()
        }
        enabledJobs.append(expsoureNotificationJob)
        
        let postcodeJob = BackgroundTaskAggregator.Job(
            work: riskyPostcodeEndpointManager.update
        )
        enabledJobs.append(postcodeJob)
        
        let localMessagingJob = BackgroundTaskAggregator.Job { [localInformationEndpointManager] in
            localInformationEndpointManager.update()
                .append(Deferred(createPublisher: localInformationEndpointManager.recordMetrics))
                .eraseToAnyPublisher()
        }
        enabledJobs.append(localMessagingJob)
        
        let checkInsManager = checkInContext.checkInsManager
        
        let deleteExpiredCheckInJob = BackgroundTaskAggregator.Job(
            work: checkInsManager.deleteExpiredCheckIns
        )
        enabledJobs.append(deleteExpiredCheckInJob)
        
        let matchRiskyVenuesJob = BackgroundTaskAggregator.Job {
            checkInsManager.evaluateVenuesRisk()
                .append(Deferred(createPublisher: circuitBreaker.processRiskyVenueApproval))
                .eraseToAnyPublisher()
        }
        enabledJobs.append(matchRiskyVenuesJob)
        
        let virologyTokenCleanupAndPollingJob = BackgroundTaskAggregator.Job { virologyTokenHousekeeper
            .executeHousekeeping()
            .append(Deferred(createPublisher: self.virologyTestingManager.evaulateTestResults))
            .eraseToAnyPublisher()
        }
        
        enabledJobs.append(virologyTokenCleanupAndPollingJob)
        
        let isolationHousekeepingJob = BackgroundTaskAggregator.Job(
            work: isolationHousekeeper.executeHousekeeping
        )
        enabledJobs.append(isolationHousekeepingJob)
        
        let riskyVenueHousekeepingJob = BackgroundTaskAggregator.Job(
            work: riskyVenueHousekeeper.executeHousekeeping
        )
        enabledJobs.append(riskyVenueHousekeepingJob)
        
        enabledJobs.append(
            contentsOf: isolationContext.makeBackgroundJobs()
        )
        
        enabledJobs.append(
            contentsOf: checkInContext.makeBackgroundJobs()
        )
        
        let symptomsCheckerHousekeepingJob = BackgroundTaskAggregator.Job(
            work: symptomsCheckerHousekeeper.executeHousekeeping
        )
        
        enabledJobs.append(symptomsCheckerHousekeepingJob)
        
        enabledJobs.append(
            contentsOf: symptomsCheckerManager.makeBackgroundJobs()
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                work: exposureNotificationContext.exposureNotificationStateController.recordMetrics
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                work: isolationPaymentContext.recordMetrics
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                work: userNotificationsStateController.recordMetrics
            )
        )
        
        let keySharingContext = self.keySharingContext
        enabledJobs.append(
            BackgroundTaskAggregator.Job {
                keySharingContext.executeHouseKeeper()
                    .append(Deferred(createPublisher: keySharingContext.showReminderNotificationIfNeeded))
                    .eraseToAnyPublisher()
            }
        )
        
        return enabledJobs
    }
    
    private func setupChangeNotifiers(using userNotificationsManager: UserNotificationManaging,
                                      localAuthority: AnyPublisher<LocalAuthority?, Never>,
                                      languageCode: AnyPublisher<String?, Never>,
                                      postcode: AnyPublisher<Postcode?, Never>,
                                      localAuthorityValidator: LocalAuthoritiesValidator) {
        let changeNotifier = ChangeNotifier(notificationManager: userNotificationsManager)
        
        let risk = postcodeInfo
            .compactMap { $0?.risk }
            .switchToLatest()
            .map { $0?.id }
            .filterNil()
        
        changeNotifier
            .alertUserToChanges(in: risk, type: .postcode)
            .store(in: &cancellables)
        
        RiskyCheckInsChangeNotifier(notificationManager: userNotificationsManager)
            .alertUserToChanges(
                in: checkInContext.checkInsStore.$mostRecentAndSevereUnacknowledgedRiskyCheckIn
                    .map { $0?.venueMessageType }
            )
            .store(in: &cancellables)
        
        LocalInformationChangeNotifier(notificationManager: userNotificationsManager)
            .alertUserToChanges(
                in: localInformation,
                localAuthority: localAuthority,
                languageCode: languageCode,
                postcode: postcode,
                localAuthorityValidator: localAuthorityValidator
            )
            .store(in: &cancellables)
        
        changeNotifier
            .alertUserToChanges(
                in: appAvailabilityManager.$metadata.map { $0.state },
                type: .appAvailability,
                shouldSend: {
                    switch $0 {
                    case .recommending: return false
                    default: return true
                    }
                }
            )
            .store(in: &cancellables)
        
        let initialState = appAvailabilityManager.metadata.state
        
        let theLastTwoStatesNextToEachOther = appAvailabilityManager
            .$metadata
            .map { $0.state }
            .scan((old: initialState, new: initialState)) { result, state in
                (old: result.new, new: state)
            }
        
        let stateThatNeverDowngradesRecommendedVersion = theLastTwoStatesNextToEachOther.map { old, new -> AppAvailabilityLogicalState in
            switch (old, new) {
            case (
                .recommending(reason: .appOlderThanRecommended(let oldVersion)),
                .recommending(reason: .appOlderThanRecommended(let newVersion))
            ):
                return .recommending(reason: .appOlderThanRecommended(version: max(oldVersion, newVersion)))
            case (
                .recommending(reason: .iOSOlderThanRecommended(let oldVersion)),
                .recommending(reason: .iOSOlderThanRecommended(let newVersion))
            ):
                return .recommending(reason: .iOSOlderThanRecommended(version: max(oldVersion, newVersion)))
            default:
                return new
            }
        }
        
        changeNotifier
            .alertUserToChanges(
                in: stateThatNeverDowngradesRecommendedVersion,
                type: .latestAppVersionAvailable,
                shouldSend: {
                    switch $0 {
                    case .recommending: return true
                    default: return false
                    }
                }
            )
            .store(in: &cancellables)
        
        IsolationStateChangeNotifier(notificationManager: userNotificationsManager)
            .alertUserToChanges(in: isolationContext.isolationStateManager.$state)
            .store(in: &cancellables)
    }
    
    private func requestPermissions() {
        exposureNotificationContext.exposureNotificationStateController.enable {
            self.userNotificationsStateController.authorize()
            self.metricReporter.didFinishOnboarding()
        }
    }
    
    public func handleUserNotificationAction(_ action: UserNotificationAction, completion: @escaping () -> Void) {
        switch action {
        case .enableExposureNotification:
            exposureNotificationContext.exposureNotificationStateController.enable(completion: completion)
        }
    }
    
    public func performBackgroundTask(task: BackgroundTask) {
        _performBackgroundTask(task: task)
    }
    
    private func _performBackgroundTask(task: BackgroundTask, counter: Int = 0) {
        // TODO: Find a more robust way of doing this.
        // If we’ve just booted, delay the tasks a little bit until we’ve settled into a new state.
        if case .starting = state, counter < 3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self._performBackgroundTask(task: task, counter: counter + 1)
            }
        } else {
            if let backgroundTaskAggregator = backgroundTaskAggregator {
                backgroundTaskAggregator.performBackgroundTask(backgroundTask: task)
            } else {
                task.setTaskCompleted(success: true)
            }
        }
    }
    
    private func deleteAllData() {
        completedOnboardingForCurrentSession.value = false
        bluetoothOffAcknowledged.value = false
        postcodeStore.delete()
        checkInContext.checkInsStore.deleteAll()
        isolationContext.isolationStateStore.isolationStateInfo = nil
        exposureNotificationContext.exposureDetectionStore.delete()
        exposureNotificationContext.exposureWindowStore?.delete()
        virologyTestingStateStore.delete()
        metricReporter.delete()
        languageStore.delete()
        isolationPaymentContext.deleteAllData()
        riskyPostcodeEndpointManager.reload()
        homeAnimationsStore.delete()
        localInformationEndpointManager.deleteCurrentInfo()
        symptomsCheckerManager.deleteAll()
        
        UserDefaults.standard.removeObject(forKey: "OpenedNewSymptomCheckerInEnglandV4_29")
    }
    
    private func deleteCheckIn(with id: String) {
        checkInContext.checkInsStore.delete(checkInId: id)
    }
    
}
