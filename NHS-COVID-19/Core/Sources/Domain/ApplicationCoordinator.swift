//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import Logging
import RiskScore
import UIKit

public class ApplicationCoordinator {
    
    private static let latestPolicyAppVersion = "3.10"
    
    private static let appAvailabilityCheckTaskFrequency = 6.0 * 60 * 60 // 6h
    private static let exposureDetectionBackgroundTaskFrequency = 2.0 * 60 * 60 // 2h
    private static let matchingRiskyPostcodeDeletionBackgroundTaskFrequency = 24.0 * 60 * 60 // 1 day
    private static let expiredCheckInsDeletionBackgroundTaskFrequency = 24.0 * 60 * 60 // 1 day
    private static let matchingRiskyVenuesDeletionBackgroundTaskFrequency = 24.0 * 60 * 60 // 1 day
    private static let pollingTestResultBackgroundTaskFrequency = 6.0 * 60 * 60 // 6h
    private static let housekeepingJobBackgroundTaskFrequency = 24.0 * 60 * 60 // 1 day
    private static let metricsJobBackgroundTaskFrequency = 24.0 * 60 * 60 // 1 day
    private static let metricsUploadJobBackgroundTaskFrequency = 24.0 * 60 * 60 // 1 day
    
    private static let logger = Logger(label: "ApplicationCoordinator")
    
    private let application: Application
    private let appAvailabilityManager: AppAvailabilityManager
    private let metricReporter: MetricReporter
    private let userNotificationsStateController: UserNotificationsStateController
    private var cancellabes = [AnyCancellable]()
    private let processingTaskRequestManager: ProcessingTaskRequestManaging
    private var backgroundTaskAggregator: BackgroundTaskAggregator?
    private let postcodeStore: PostcodeStore
    private let distributeClient: HTTPClient
    private let selfDiagnosisManager: SelfDiagnosisManager
    private let exposureNotificationContext: ExposureNotificationContext
    private let checkInContext: CheckInContext
    private let isolationContext: IsolationContext
    private let riskyPostcodeEndpointManager: RiskyPostcodeEndpointManager
    private let postcodeInfo: DomainProperty<(postcode: Postcode, localAuthority: LocalAuthority?, risk: DomainProperty<RiskyPostcodeEndpointManager.PostcodeRisk?>)?>
    private let savePostcode: (String) -> Result<Void, PostcodeValidationError>
    private let notificationCenter: NotificationCenter
    private let virologyTestingManager: VirologyTestingManager
    private let virologyTestingStateStore: VirologyTestingStateStore
    private let circuitBreaker: CircuitBreaker
    private let housekeeper: Housekeeper
    private let exposureNotificationReminder: ExposureNotificationReminder
    private let completedOnboardingForCurrentSession = CurrentValueSubject<Bool, Never>(false)
    private let appReviewPresenter: AppReviewPresenter
    public let country: DomainProperty<Country>
    private let shouldRecommendUpdate = CurrentValueSubject<Bool, Never>(true)
    private let policyManager: PolicyVersionManager
    private let localAuthorityManager: LocalAuthorityManager
    private let isolationPaymentContext: IsolationPaymentContext
    private let trafficObfuscationClient: TrafficObfuscationClient
    private let userNotificationManager: UserNotificationManaging
    
    private var recommendedUpdateManager: RecommendedUpdateManager?
    
    @Published
    public var state = ApplicationState.starting
    
    private var currentDateProvider: DateProviding
    private var languageStore: LanguageStore
    
    public let localeConfiguration: DomainProperty<LocaleConfiguration>
    
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
        localeConfiguration = languageStore.$configuration.domainProperty()
        
        appAvailabilityManager = AppAvailabilityManager(
            distributeClient: distributeClient,
            iTunesClient: services.iTunesClient,
            cacheStorage: services.cacheStorage,
            appInfo: services.appInfo
        )
        
        let postcodeStore = PostcodeStore(store: services.encryptedStore)
        
        let localAuthorityValidator = LocalAuthoritiesValidator()
        
        let localAuthority = postcodeStore.$localAuthorityId.map { localAuthorityId -> LocalAuthority? in
            guard let localAuthorityId = localAuthorityId else { return nil }
            return localAuthorityValidator.localAuthority(with: localAuthorityId)
        }
        
        let riskyPostcodeEndpointManager = RiskyPostcodeEndpointManager(
            distributeClient: distributeClient,
            storage: services.cacheStorage,
            postcode: postcodeStore.$postcode.eraseToAnyPublisher(),
            localAuthority: localAuthority.eraseToAnyPublisher()
        )
        
        postcodeInfo = riskyPostcodeEndpointManager.postcodeInfo
        savePostcode = { (postcodeValue: String) in
            let result = services.postcodeValidator.validatedPostcode(from: postcodeValue)
            if case .success(let postcode) = result {
                postcodeStore.save(postcode: postcode)
            }
            return result.map { _ in }
        }
        
        self.riskyPostcodeEndpointManager = riskyPostcodeEndpointManager
        self.postcodeStore = postcodeStore
        
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
            }
        )
        let isolationContext = self.isolationContext
        
        selfDiagnosisManager = SelfDiagnosisManager(httpClient: distributeClient) { onsetDay in
            let info = IndexCaseInfo(isolationTrigger: .selfDiagnosis(dateProvider.currentGregorianDay(timeZone: .current)), onsetDay: onsetDay, testInfo: nil)
            return IsolationState(logicalState: isolationContext.isolationStateStore.set(info))
        }
        
        let checkInsStore = CheckInsStore(store: services.encryptedStore, venueDecoder: services.venueDecoder)
        checkInContext = CheckInContext(
            checkInsStore: checkInsStore,
            checkInsManager: CheckInsManager(checkInsStore: checkInsStore, httpClient: distributeClient),
            qrCodeScanner: QRCodeScanner(
                cameraManager: services.cameraManager,
                cameraStateController: CameraStateController(
                    manager: services.cameraManager,
                    notificationCenter: notificationCenter
                )
            )
        )
        
        virologyTestingStateStore = VirologyTestingStateStore(store: services.encryptedStore)
        virologyTestingManager = VirologyTestingManager(
            httpClient: services.apiClient,
            virologyTestingStateCoordinator: VirologyTestingStateCoordinator(
                virologyTestingStateStore: virologyTestingStateStore,
                userNotificationsManager: services.userNotificationsManager
            ),
            ctaTokenValidator: CTATokenValidator(),
            country: { country.currentValue }
        )
        
        let isolationStateManager = isolationContext.isolationStateManager
        
        let interestedInExposureNotifications = { isolationStateManager.state.interestedInExposureNotifications }
        
        isolationPaymentContext = IsolationPaymentContext(
            services: services,
            country: country,
            isolationState: isolationStateManager.$state.domainProperty(),
            isolationStateStore: isolationContext.isolationStateStore
        )
        
        exposureNotificationContext = ExposureNotificationContext(
            services: services,
            isolationLength: isolationContext.isolationConfiguration.value.contactCase,
            interestedInExposureNotifications: interestedInExposureNotifications,
            getPostcode: { postcodeStore.postcode },
            getLocalAuthority: { postcodeStore.localAuthorityId }
        )
        
        userNotificationsStateController = UserNotificationsStateController(
            manager: services.userNotificationsManager,
            notificationCenter: notificationCenter
        )
        
        metricReporter = MetricReporter(
            client: services.apiClient,
            encryptedStore: services.encryptedStore,
            currentDateProvider: currentDateProvider,
            appInfo: services.appInfo,
            getPostcode: { postcodeStore.postcode?.value },
            getLocalAuthority: { postcodeStore.localAuthorityId?.value }
        )
        
        circuitBreaker = CircuitBreaker(
            client: CircuitBreakerClient(httpClient: services.apiClient),
            exposureInfoProvider: exposureNotificationContext.exposureDetectionStore,
            riskyCheckinsProvider: checkInContext.checkInsStore,
            handleContactCase: { riskInfo in
                let contactCaseInfo = ContactCaseInfo(exposureDay: riskInfo.day, isolationFromStartOfDay: dateProvider.currentGregorianDay(timeZone: .current))
                isolationContext.isolationStateStore.set(contactCaseInfo)
                services.userNotificationsManager.removePending(type: .exposureDontWorry)
                services.userNotificationsManager.add(type: .exposureDetection, at: nil, withCompletionHandler: nil)
            },
            handleDontWorryNotification: exposureNotificationContext.handleDontWorryNotification,
            interestedInExposureNotifications: interestedInExposureNotifications
        )
        
        housekeeper = Housekeeper(
            isolationStateStore: isolationContext.isolationStateStore,
            isolationStateManager: isolationStateManager,
            virologyTestingStateStore: virologyTestingStateStore,
            getToday: { dateProvider.currentGregorianDay(timeZone: .current) }
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
        
        trafficObfuscationClient = TrafficObfuscationClient(client: services.apiClient)
        
        metricReporter.set(rawState: rawState.domainProperty())

        monitorRawState()
        
        setupBackgroundTask()
        
        setupChangeNotifiers(using: services.userNotificationsManager)
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
            .store(in: &cancellabes)
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
            return .failedToStart
        case .onboarding:
            let completedOnboardingForCurrentSession = self.completedOnboardingForCurrentSession
            return .onboarding(
                complete: { [weak self] in
                    self?.policyManager.acceptWithCurrentAppVersion()
                    completedOnboardingForCurrentSession.value = true
                },
                openURL: application.open
            )
        case .authorizationRequired:
            return .authorizationRequired(requestPermissions: requestPermissions, country: country)
        case .canNotRunExposureNotification(let reason):
            return .canNotRunExposureNotification(reason: disabledReason(from: reason), country: country.currentValue)
        case .postcodeAndLocalAuthorityRequired:
            return .postcodeAndLocalAuthorityRequired(openURL: application.open, getLocalAuthorities: localAuthorityManager.localAuthorities, storeLocalAuthority: localAuthorityManager.store)
        case .localAuthorityRequired:
            if let postcode = postcodeStore.postcode {
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
            let isolationStateStore = isolationContext.isolationStateStore
            
            return .runningExposureNotification(
                RunningAppContext(
                    checkInContext: checkInContext,
                    postcodeInfo: postcodeInfo,
                    savePostcode: savePostcode,
                    country: country,
                    openSettings: application.openSettings,
                    openURL: application.open,
                    selfDiagnosisManager: selfDiagnosisManager,
                    isolationState: isolationContext.isolationStateManager.$state
                        .map(IsolationState.init)
                        .domainProperty(),
                    testInfo: isolationStateStore.$isolationStateInfo.map { $0?.isolationInfo.indexCaseInfo?.testInfo }.domainProperty(),
                    isolationAcknowledgementState: isolationContext.makeIsolationAcknowledgementState(),
                    exposureNotificationStateController: exposureNotificationContext.exposureNotificationStateController,
                    virologyTestingManager: virologyTestingManager,
                    testResultAcknowledgementState: makeResultAcknowledgementState(),
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
                    storeLocalAuthorities: localAuthorityManager.store,
                    isolationPaymentState: isolationPaymentContext.isolationPaymentState,
                    currentLocaleConfiguration: languageStore.$configuration.domainProperty(),
                    storeNewLanguage: languageStore.save
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
        
        return checkInContext.checkInsStore.$lastUnacknowledgedRiskyCheckIns
            .removeDuplicates()
            .map { lastRiskyCheckIn in
                if let lastRiskyCheckIn = lastRiskyCheckIn {
                    return .needed(
                        acknowledge: checkInContext.checkInsStore.acknowldegeRiskyCheckIns,
                        venueName: lastRiskyCheckIn.venueName,
                        checkInDate: lastRiskyCheckIn.checkedIn.date
                    )
                }
                return RiskyCheckInsAcknowledgementState.notNeeded
            }
            .eraseToAnyPublisher()
    }
    
    private func makeResultAcknowledgementState() -> AnyPublisher<TestResultAcknowledgementState, Never> {
        virologyTestingStateStore.$virologyTestResult
            .map { [weak self] result -> AnyPublisher<TestResultAcknowledgementState, Never> in
                guard let self = self, let result = result else {
                    return Just(.notNeeded).eraseToAnyPublisher()
                }
                
                return self.isolationContext.makeResultAcknowledgementState(
                    result: result,
                    positiveAcknowledgement: self.exposureNotificationContext.positiveAcknowledgement
                ) { [weak self] shareKeyState in
                    guard let self = self else { return }
                    self.virologyTestingStateStore.remove(testResult: result)
                    
                    if case .notSent = shareKeyState {
                        self.trafficObfuscationClient.sendSingleTraffic(for: TrafficObfuscator.keySubmission)
                    }
                    
                    self.exposureNotificationContext.postExposureWindows(
                        result: result.testResult,
                        testKitType: result.testKitType,
                        requiresConfirmatoryTest: result.requiresConfirmatoryTest
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
        case .bluetoothDisabled:
            return .bluetoothDisabled
        }
    }
    
    private var rawState: AnyPublisher<RawState, Never> {
        return appAvailabilityManager.$metadata
            .combineLatest(completedOnboardingForCurrentSession, shouldRecommendUpdate, policyManager.$needsAcceptNewVersion)
            .combineLatest(exposureNotificationContext.exposureNotificationStateController.combinedState, userNotificationsStateController.$authorizationStatus, postcodeStore.$state)
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
                self.backgroundTaskAggregator?.performBackgroundTask(backgroundTask: NoOpBackgroundTask())
            }
        }.store(in: &cancellabes)
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
            preferredFrequency: Self.appAvailabilityCheckTaskFrequency,
            work: appAvailabilityManager.update
        )
        
        var enabledJobs = [availabilityCheck]
        
        switch state {
        case .runningExposureNotification,
             .policyAcceptanceRequired,
             .localAuthorityRequired,
             .postcodeAndLocalAuthorityRequired where postcodeStore.postcode != nil,
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
        
        return enabledJobs
    }
    
    private func makeBackgroundJobsForRunningState() -> [BackgroundTaskAggregator.Job] {
        var enabledJobs = [BackgroundTaskAggregator.Job]()
        
        let circuitBreaker = self.circuitBreaker
        let isolationPaymentContext = self.isolationPaymentContext
        let exposureNotificationContext = self.exposureNotificationContext
        let isolationContext = self.isolationContext
        let exposureWindowHouskeeper = ExposureWindowHousekeeper(
            getIsolationLogicalState: { isolationContext.isolationStateManager.state },
            isWaitingForExposureApproval: { exposureNotificationContext.isWaitingForApproval },
            clearExposureWindowData: exposureNotificationContext.deleteExposureWindows
        )
        let expsoureNotificationJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.exposureDetectionBackgroundTaskFrequency
        ) {
            exposureNotificationContext.detectExposures(
                deferShouldShowDontWorryNotification: {
                    circuitBreaker.showDontWorryNotificationIfNeeded = true
                }
            )
            .append(Deferred(createPublisher: { exposureNotificationContext.resendExposureDetectionNotificationIfNeeded(isolationContext: isolationContext) }))
            .append(Deferred(createPublisher: circuitBreaker.processExposureNotificationApproval))
            .append(Deferred(createPublisher: isolationPaymentContext.processCanApplyForFinancialSupport))
            .append(Deferred(createPublisher: exposureWindowHouskeeper.executeHousekeeping))
            
            .eraseToAnyPublisher()
        }
        enabledJobs.append(expsoureNotificationJob)
        
        let postcodeJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.exposureDetectionBackgroundTaskFrequency,
            work: riskyPostcodeEndpointManager.update
        )
        enabledJobs.append(postcodeJob)
        
        let checkInsManager = checkInContext.checkInsManager
        
        let deleteExpiredCheckInJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.expiredCheckInsDeletionBackgroundTaskFrequency,
            work: checkInsManager.deleteExpiredCheckIns
        )
        enabledJobs.append(deleteExpiredCheckInJob)
        
        let matchRiskyVenuesJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.matchingRiskyVenuesDeletionBackgroundTaskFrequency
        ) {
            checkInsManager.evaluateVenuesRisk()
                .append(Deferred(createPublisher: circuitBreaker.processRiskyVenueApproval))
                .eraseToAnyPublisher()
        }
        enabledJobs.append(matchRiskyVenuesJob)
        
        let pollingTestResultsJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.pollingTestResultBackgroundTaskFrequency,
            work: virologyTestingManager.evaulateTestResults
        )
        enabledJobs.append(pollingTestResultsJob)
        
        let housekeepingJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.housekeepingJobBackgroundTaskFrequency,
            work: housekeeper.executeHousekeeping
        )
        enabledJobs.append(housekeepingJob)
        
        enabledJobs.append(
            contentsOf: isolationContext.makeBackgroundJobs(
                metricsFrequency: Self.metricsJobBackgroundTaskFrequency,
                housekeepingFrequency: Self.housekeepingJobBackgroundTaskFrequency
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.housekeepingJobBackgroundTaskFrequency,
                work: exposureNotificationContext.exposureNotificationStateController.recordMetrics
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.metricsJobBackgroundTaskFrequency,
                work: isolationPaymentContext.recordMetrics
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.metricsJobBackgroundTaskFrequency,
                work: userNotificationsStateController.recordMetrics
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.metricsUploadJobBackgroundTaskFrequency,
                work: metricReporter.uploadMetrics
            )
        )
        
        return enabledJobs
    }
    
    private func setupChangeNotifiers(using userNotificationsManager: UserNotificationManaging) {
        let changeNotifier = ChangeNotifier(notificationManager: userNotificationsManager)
        
        let risk = postcodeInfo
            .compactMap { $0?.risk }
            .switchToLatest()
            .map { $0?.id }
            .filterNil()
        
        changeNotifier
            .alertUserToChanges(in: risk, type: .postcode)
            .store(in: &cancellabes)
        
        RiskyCheckInsChangeNotifier(notificationManager: userNotificationsManager)
            .alertUserToChanges(in: checkInContext.checkInsStore.$unacknowledgedRiskyCheckIns)
            .store(in: &cancellabes)
        
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
            .store(in: &cancellabes)
        
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
            .store(in: &cancellabes)
        
        IsolationStateChangeNotifier(notificationManager: userNotificationsManager)
            .alertUserToChanges(in: isolationContext.isolationStateManager.$state)
            .store(in: &cancellabes)
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
        postcodeStore.delete()
        checkInContext.checkInsStore.deleteAll()
        isolationContext.isolationStateStore.isolationStateInfo = nil
        exposureNotificationContext.exposureDetectionStore.delete()
        exposureNotificationContext.exposureWindowStore?.delete()
        virologyTestingStateStore.delete()
        metricReporter.delete()
        languageStore.delete()
    }
    
    private func deleteCheckIn(with id: String) {
        checkInContext.checkInsStore.delete(checkInId: id)
    }
    
}
