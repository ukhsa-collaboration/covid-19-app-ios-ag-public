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
    private let metricRecoder: MetricReporter
    private let userNotificationsStateController: UserNotificationsStateController
    private var cancellabes = [AnyCancellable]()
    private let processingTaskRequestManager: ProcessingTaskRequestManaging
    private var backgroundTaskAggregator: BackgroundTaskAggregator?
    private let postcodeStore: PostcodeStore
    private let distributeClient: HTTPClient
    private let selfDiagnosisManager: SelfDiagnosisManager?
    private let exposureNotificationContext: ExposureNotificationContext
    private let checkInContext: CheckInContext
    private let isolationContext: IsolationContext
    private let riskyPostcodeEndpointManager: RiskyPostcodeEndpointManager
    private let postcodeInfo: DomainProperty<(postcode: Postcode, risk: DomainProperty<RiskyPostcodeEndpointManager.PostcodeRisk?>)?>
    private let savePostcode: (String) -> Result<Void, PostcodeValidationError>
    private let notificationCenter: NotificationCenter
    private let virologyTestingManager: VirologyTestingManager
    private let virologyTestingStateStore: VirologyTestingStateStore
    private let riskScoreNegotiator: RiskScoreNegotiator
    private let circuitBreaker: CircuitBreaker
    private let housekeeper: Housekeeper
    private let diagnosisKeyCacheHouskeeper: DiagnosisKeyCacheHousekeeper
    private let exposureNotificationReminder: ExposureNotificationReminder
    private let completedOnboardingForCurrentSession = CurrentValueSubject<Bool, Never>(false)
    private let appReviewPresenter: AppReviewPresenter
    public let country: DomainProperty<Country>
    private let handleDontWorryNotification: () -> Void
    private let shouldRecommendUpdate = CurrentValueSubject<Bool, Never>(true)
    private let policyManager: PolicyVersionManager
    
    public let pasteboardCopier: PasteboardCopying
    private var recommendedUpdateManager: RecommendedUpdateManager?
    
    @Published
    public var state = ApplicationState.starting
    
    private var currentDateProvider: () -> Date
    
    public init(services: ApplicationServices, enabledFeatures: [Feature]) {
        application = services.application
        notificationCenter = services.notificationCenter
        processingTaskRequestManager = services.processingTaskRequestManager
        distributeClient = services.distributeClient
        pasteboardCopier = services.pasteboardCopier
        currentDateProvider = services.currentDateProvider
        
        Self.logger.debug("Initialising")
        
        appAvailabilityManager = AppAvailabilityManager(
            distributeClient: distributeClient,
            iTunesClient: services.iTunesClient,
            cacheStorage: services.cacheStorage,
            appInfo: services.appInfo
        )
        
        let postcodeStore = PostcodeStore(store: services.encryptedStore)
        
        let riskyPostcodeEndpointManager = RiskyPostcodeEndpointManager(
            distributeClient: distributeClient,
            storage: services.cacheStorage,
            postcode: postcodeStore.$postcode.eraseToAnyPublisher()
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
            currentDateProvider: currentDateProvider
        )
        let isolationContext = self.isolationContext
        
        if enabledFeatures.contains(.selfDiagnosis) {
            selfDiagnosisManager = SelfDiagnosisManager(httpClient: distributeClient) { onsetDay in
                let info = IndexCaseInfo(isolationTrigger: .selfDiagnosis(.today), onsetDay: onsetDay, testInfo: nil)
                return IsolationState(logicalState: isolationContext.isolationStateStore.set(info))
            }
        } else {
            selfDiagnosisManager = nil
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
            ctaTokenValidator: CTATokenValidator()
        )
        
        let isolationStateManager = isolationContext.isolationStateManager
        exposureNotificationContext = ExposureNotificationContext(
            exposureNotificationManager: services.exposureNotificationManager,
            encryptedStore: services.encryptedStore,
            isolationLength: isolationContext.isolationConfiguration.value.contactCase,
            currentDateProvider: currentDateProvider,
            apiClient: services.apiClient,
            distributeClient: services.distributeClient,
            cacheStorage: services.cacheStorage,
            interestedInExposureNotifications: { isolationStateManager.state.isolation?.interestedInExposureNotifications ?? true
            }
        )
        
        userNotificationsStateController = UserNotificationsStateController(
            manager: services.userNotificationsManager,
            notificationCenter: notificationCenter
        )
        
        metricRecoder = MetricReporter(
            manager: services.metricManager,
            client: services.apiClient,
            encryptedStore: services.encryptedStore,
            currentDateProvider: currentDateProvider,
            appInfo: services.appInfo
        ) {
            postcodeStore.postcode?.value ?? ""
        }
        
        riskScoreNegotiator = RiskScoreNegotiator(
            isolationStateManager: isolationStateManager,
            exposureDetectionStore: exposureNotificationContext.exposureDetectionStore
        )
        
        riskScoreNegotiator
            .deleteRiskIfIsolating()
            .store(in: &cancellabes)
        
        // Show the "Don't worry" notification if the EN API returns an exposure but our own logic does not consider
        // it as risky (and therefore does not send the user to isolation)
        handleDontWorryNotification = {
            services.userNotificationsManager.add(type: .exposureDontWorry, at: nil, withCompletionHandler: nil)
        }
        
        circuitBreaker = CircuitBreaker(
            client: CircuitBreakerClient(httpClient: services.apiClient),
            exposureInfoProvider: exposureNotificationContext.exposureDetectionStore,
            riskyCheckinsProvider: checkInContext.checkInsStore,
            handleContactCase: { riskInfo in
                let contactCaseInfo = ContactCaseInfo(exposureDay: riskInfo.day, isolationFromStartOfDay: .today, trigger: .exposureDetection)
                isolationContext.isolationStateStore.set(contactCaseInfo)
                services.userNotificationsManager.removePending(type: .exposureDontWorry)
                services.userNotificationsManager.add(type: .exposureDetection, at: nil, withCompletionHandler: nil)
            },
            handleDontWorryNotification: handleDontWorryNotification
        )
        
        housekeeper = Housekeeper(
            isolationStateStore: isolationContext.isolationStateStore,
            isolationStateManager: isolationStateManager,
            virologyTestingStateStore: virologyTestingStateStore
        )
        
        diagnosisKeyCacheHouskeeper = DiagnosisKeyCacheHousekeeper(
            fileStorage: services.cacheStorage,
            exposureDetectionStore: exposureNotificationContext.exposureDetectionStore,
            currentDateProvider: currentDateProvider
        )
        
        exposureNotificationReminder = ExposureNotificationReminder(
            userNotificationManager: services.userNotificationsManager,
            userNotificationStateController: userNotificationsStateController,
            currentDateProvider: currentDateProvider,
            exposureNotificationEnabled: exposureNotificationContext.exposureNotificationStateController.isEnabledPublisher
        )
        
        country = postcodeStore.$postcode.map { postcode in
            if let postcode = postcode {
                return services.postcodeValidator.country(for: postcode) ?? Country.england
            }
            return Country.england
        }
        .eraseToAnyPublisher()
        .domainProperty()
        
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
        case .postcodeRequired:
            return .postcodeRequired(savePostcode: savePostcode)
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
                    symptomsDateAndEncounterDateProvider: isolationStateStore,
                    deleteAllData: { [weak self] in
                        self?.deleteAllData()
                    },
                    deleteCheckIn: { [weak self] id in
                        self?.deleteCheckIn(with: id)
                    },
                    riskyCheckInsAcknowledgementState: makeRiskyCheckInsAcknowledgementState(),
                    currentDateProvider: currentDateProvider,
                    exposureNotificationReminder: exposureNotificationReminder,
                    appReviewPresenter: appReviewPresenter
                )
            )
        case .recommendingUpdate(let reason, let titles, let descriptions):
            recommendedUpdateManager = RecommendedUpdateManager(notificationCenter: notificationCenter, recommendedUpdateAction: { [weak self] in
                self?.shouldRecommendUpdate.value = true
            })
            switch reason {
            case .appOlderThanRecommended:
                return .recommmededUpdate(ApplicationState.RecommendedUpdateReason.newRecommendedAppUpdate(title: titles, descriptions: descriptions, dismissAction: { [weak self] in
                    self?.shouldRecommendUpdate.value = false
                }))
            case .iOSOlderThanRecommended:
                return .recommmededUpdate(ApplicationState.RecommendedUpdateReason.newRecommendedOSupdate(title: titles, descriptions: descriptions, dismissAction: { [weak self] in
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
    
    private func positiveAcknowledgement(
        for token: DiagnosisKeySubmissionToken,
        endDate: Date?,
        indexCaseInfo: IndexCaseInfo?,
        completionHandler: @escaping () -> Void
    ) -> TestResultAcknowledgementState.PositiveResultAcknowledgement {
        TestResultAcknowledgementState.PositiveResultAcknowledgement(
            acknowledge: { [weak self] in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                
                if let indexCaseInfo = indexCaseInfo {
                    return self.exposureNotificationContext.exposureKeysManager.sendKeys(
                        for: indexCaseInfo.assumedOnsetDay,
                        token: token
                    )
                    .catch { (error) -> AnyPublisher<Void, Error> in
                        if (error as NSError).domain == ENErrorDomain {
                            return Empty().eraseToAnyPublisher()
                        } else {
                            return Fail(error: error).eraseToAnyPublisher()
                        }
                    }
                    .handleEvents(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            completionHandler()
                        case .failure:
                            break
                        }
                    })
                    .eraseToAnyPublisher()
                } else {
                    completionHandler()
                    return Result.success(()).publisher.eraseToAnyPublisher()
                }
            },
            acknowledgeWithoutSending: { completionHandler() }
        )
    }
    
    private func makeResultAcknowledgementState() -> AnyPublisher<TestResultAcknowledgementState, Never> {
        virologyTestingStateStore.$virologyTestResult
            .combineLatest(isolationContext.isolationStateStore.$isolationStateInfo, notificationCenter.today)
            .map { [weak self] result, isolationStateInfo, _ in
                guard let self = self, let result = result else {
                    return TestResultAcknowledgementState.notNeeded
                }
                
                let isolationStateStore = self.isolationContext.isolationStateStore
                let newIsolationStateInfo = isolationStateStore.newIsolationStateInfo(
                    for: result.testResult,
                    receivedOn: .today,
                    npexDay: GregorianDay(date: result.endDate, timeZone: .utc)
                )
                
                let newIsolationState = IsolationLogicalState(stateInfo: newIsolationStateInfo, day: .today)
                let currentIsolationState = IsolationLogicalState(stateInfo: isolationStateInfo, day: .today)
                
                return TestResultAcknowledgementState(
                    result: result,
                    newIsolationState: newIsolationState,
                    currentIsolationState: currentIsolationState,
                    indexCaseInfo: newIsolationStateInfo.isolationInfo.indexCaseInfo,
                    positiveAcknowledgement: self.positiveAcknowledgement
                ) {
                    self.virologyTestingStateStore.remove(testResult: result)
                    
                    isolationStateStore.isolationStateInfo = newIsolationStateInfo
                    
                    if !newIsolationState.isIsolating {
                        isolationStateStore.acknowldegeEndOfIsolation()
                    }
                    
                    if !currentIsolationState.isIsolating, newIsolationState.isIsolating {
                        isolationStateStore.restartIsolationAcknowledgement()
                    }
                }
            }
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
            .combineLatest(exposureNotificationContext.exposureNotificationStateController.combinedState, userNotificationsStateController.$authorizationStatus, postcodeStore.$hasPostcode)
            .map { f in
                RawState(
                    appAvailability: f.0.0,
                    completedOnboardingForCurrentSession: f.0.1,
                    exposureState: f.1,
                    userNotificationsStatus: f.2,
                    hasPostcode: f.3,
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
        
        if case ApplicationState.runningExposureNotification = state {
            enabledJobs.append(contentsOf: makeBackgroundJobsForRunningState())
        }
        
        return enabledJobs
    }
    
    private func makeBackgroundJobsForRunningState() -> [BackgroundTaskAggregator.Job] {
        var enabledJobs = [BackgroundTaskAggregator.Job]()
        
        let circuitBreaker = self.circuitBreaker
        let exposureDetectionManager = exposureNotificationContext.exposureDetectionManager
        let riskScoreNegotiator = self.riskScoreNegotiator
        let handleDontWorryNotification = self.handleDontWorryNotification
        let diagnosisKeyCacheHouskeeper = self.diagnosisKeyCacheHouskeeper
        let expsoureNotificationJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.exposureDetectionBackgroundTaskFrequency
        ) {
            diagnosisKeyCacheHouskeeper.deleteFilesOlderThanADay()
                .append(
                    exposureDetectionManager.detectExposures(currentDate: self.currentDateProvider())
                        .filterNil()
                        .map { riskInfo in
                            let riskHandled = riskScoreNegotiator.saveIfNeeded(exposureRiskInfo: riskInfo)
                            if !riskHandled, riskInfo.shouldShowDontWorryNotification {
                                handleDontWorryNotification()
                            } else {
                                circuitBreaker.showDontWorryNotificationIfNeeded = true
                            }
                        }
                )
                .append(Deferred(createPublisher: circuitBreaker.processExposureNotificationApproval))
                .append(Deferred(createPublisher: diagnosisKeyCacheHouskeeper.deleteNotNeededFiles))
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
                housekeepingFrequenzy: Self.housekeepingJobBackgroundTaskFrequency
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
                preferredFrequency: Self.metricsUploadJobBackgroundTaskFrequency,
                work: metricRecoder.uploadMetrics
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
            self.metricRecoder.didFinishOnboarding()
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
        virologyTestingStateStore.delete()
    }
    
    private func deleteCheckIn(with id: String) {
        checkInContext.checkInsStore.delete(checkInId: id)
    }
    
}
