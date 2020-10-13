//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import Logging
import UIKit

public class ApplicationCoordinator {
    
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
    private var appActivationManager: AppActivationManager?
    private let metricRecoder: MetricReporter
    private let exposureNotificationStateController: ExposureNotificationStateController
    private let userNotificationsStateController: UserNotificationsStateController
    private var cancellabes = [AnyCancellable]()
    private let exposureNotificationManager: ExposureNotificationManaging
    private let processingTaskRequestManager: ProcessingTaskRequestManaging
    private var backgroundTaskAggregator: BackgroundTaskAggregator?
    private let postcodeStore: PostcodeStore?
    private let exposureDetectionStore: ExposureDetectionStore
    private let exposureDetectionManager: ExposureDetectionManager
    private let distributeClient: HTTPClient
    private let selfDiagnosisManager: SelfDiagnosisManager?
    private let checkInContext: CheckInContext?
    private let isolationStateStore: IsolationStateStore
    private let isolationStateManager: IsolationStateManager
    private let isolationConfiguration: CachedResponse<IsolationConfiguration>
    private let riskyPostcodeEndpointManager: RiskyPostcodeEndpointManager?
    private let postcodeInfo: DomainProperty<(postcode: Postcode, risk: DomainProperty<RiskyPostcodeEndpointManager.PostcodeRisk?>)?>?
    private let savePostcode: (String) -> Result<Void, PostcodeValidationError>
    private let notificationCenter: NotificationCenter
    private let virologyTestingManager: VirologyTestingManager
    private let virologyTestingStateStore: VirologyTestingStateStore
    private let riskScoreNegotiator: RiskScoreNegotiator
    private let circuitBreaker: CircuitBreaker
    private let housekeeper: Housekeeper
    private let exposureNotificationReminder: ExposureNotificationReminder
    private let completedOnboardingForCurrentSession = CurrentValueSubject<Bool, Never>(false)
    private let appReviewPresenter: AppReviewPresenter
    public let country: DomainProperty<Country>
    private let handleDontWorryNotification: () -> Void
    
    public let pasteboardCopier: PasteboardCopying
    
    @Published
    public var state = ApplicationState.starting
    
    private var currentDateProvider: () -> Date
    
    public init(services: ApplicationServices, enabledFeatures: [Feature]) {
        application = services.application
        notificationCenter = services.notificationCenter
        processingTaskRequestManager = services.processingTaskRequestManager
        exposureNotificationManager = services.exposureNotificationManager
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
        
        if enabledFeatures.contains(.pilotActivation) {
            appActivationManager = AppActivationManager(store: services.encryptedStore, httpClient: services.apiClient)
        } else {
            appActivationManager = nil
        }
        
        if enabledFeatures.contains(.riskyPostcode) {
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
        } else {
            postcodeStore = nil
            riskyPostcodeEndpointManager = nil
            postcodeInfo = nil
            savePostcode = { _ in .success(()) }
        }
        
        isolationConfiguration = CachedResponse(
            httpClient: distributeClient,
            endpoint: IsolationConfigurationEndpoint(),
            storage: services.cacheStorage,
            name: "isolation_configuration",
            initialValue: .default
        )
        
        let isolationConfiguration = self.isolationConfiguration
        let isolationStateStore = IsolationStateStore(store: services.encryptedStore) { isolationConfiguration.value }
        self.isolationStateStore = isolationStateStore
        
        isolationStateManager = IsolationStateManager(stateStore: isolationStateStore, notificationCenter: notificationCenter)
        
        if enabledFeatures.contains(.selfDiagnosis) {
            selfDiagnosisManager = SelfDiagnosisManager(httpClient: distributeClient) { onsetDay in
                let info = IndexCaseInfo(isolationTrigger: .selfDiagnosis(.today), onsetDay: onsetDay, testInfo: nil)
                return IsolationState(logicalState: isolationStateStore.set(info))
            }
        } else {
            selfDiagnosisManager = nil
        }
        
        if enabledFeatures.contains(.venueCheckIn) {
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
        } else {
            checkInContext = nil
        }
        
        exposureDetectionStore = ExposureDetectionStore(store: services.encryptedStore)
        
        virologyTestingStateStore = VirologyTestingStateStore(store: services.encryptedStore)
        virologyTestingManager = VirologyTestingManager(
            httpClient: services.apiClient,
            virologyTestingStateCoordinator: VirologyTestingStateCoordinator(
                virologyTestingStateStore: virologyTestingStateStore,
                userNotificationsManager: services.userNotificationsManager
            )
        )
        
        let isolationStateManager = self.isolationStateManager
        exposureDetectionManager = ExposureDetectionManager(
            manager: exposureNotificationManager,
            distributionClient: distributeClient,
            submissionClient: services.apiClient,
            encryptedStore: services.encryptedStore,
            transmissionRiskLevelApplier: services.transmissionRiskLevelApplier,
            interestedInExposureNotifications: { isolationStateManager.state.isolation?.interestedInExposureNotifications ?? true }
        )
        
        exposureNotificationStateController = ExposureNotificationStateController(manager: exposureNotificationManager)
        exposureNotificationStateController.activate()
        
        userNotificationsStateController = UserNotificationsStateController(
            manager: services.userNotificationsManager,
            notificationCenter: notificationCenter
        )
        
        let postcodeStore = self.postcodeStore
        metricRecoder = MetricReporter(
            manager: services.metricManager,
            client: services.apiClient,
            encryptedStore: services.encryptedStore,
            currentDateProvider: currentDateProvider,
            appInfo: services.appInfo
        ) {
            postcodeStore?.postcode?.value ?? ""
        }
        
        riskScoreNegotiator = RiskScoreNegotiator(
            isolationStateManager: isolationStateManager,
            exposureDetectionStore: exposureDetectionStore
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
            exposureInfoProvider: exposureDetectionStore,
            riskyCheckinsProvider: checkInContext?.checkInsStore ?? NoOpRiskyCheckinsProvider(),
            handleContactCase: { riskInfo in
                let contactCaseInfo = ContactCaseInfo(exposureDay: riskInfo.day, isolationFromStartOfDay: .today)
                isolationStateStore.set(contactCaseInfo)
                services.userNotificationsManager.removePending(type: .exposureDontWorry)
                services.userNotificationsManager.add(type: .exposureDetection, at: nil, withCompletionHandler: nil)
            },
            handleDontWorryNotification: handleDontWorryNotification
        )
        
        housekeeper = Housekeeper(
            isolationStateStore: isolationStateStore,
            isolationStateManager: isolationStateManager,
            virologyTestingStateStore: virologyTestingStateStore
        )
        
        exposureNotificationReminder = ExposureNotificationReminder(
            userNotificationManager: services.userNotificationsManager,
            userNotificationStateController: userNotificationsStateController,
            currentDateProvider: currentDateProvider,
            exposureNotificationEnabled: exposureNotificationStateController.isEnabledPublisher
        )
        
        if let postcodeStore = postcodeStore {
            country = postcodeStore.$postcode.map { postcode in
                if let postcode = postcode {
                    return services.postcodeValidator.country(for: postcode) ?? Country.england
                }
                return Country.england
            }
            .eraseToAnyPublisher()
            .domainProperty()
        } else {
            country = Just(Country.england).eraseToAnyPublisher().domainProperty()
        }
        
        appReviewPresenter = AppReviewPresenter(
            checkInsStore: checkInContext?.checkInsStore,
            reviewController: services.storeReviewController,
            currentDateProvider: currentDateProvider
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
        case .appUnavailable(let logicalReason):
            let reason: ApplicationState.AppUnavailabilityReason
            switch logicalReason {
            case .iOSTooOld(let descriptions):
                reason = .iOSTooOld(descriptions: descriptions)
            case .appTooOld(let updateAvailable, let descriptions):
                reason = .appTooOld(updateAvailable: updateAvailable, descriptions: descriptions)
            }
            return .appUnavailable(reason)
        case .pilotActivationRequired:
            guard let appActivationManager = appActivationManager else { return .failedToStart }
            return .pilotActivationRequired(submit: appActivationManager.activate(with:))
        case .failedToStart:
            return .failedToStart
        case .onboarding:
            let completedOnboardingForCurrentSession = self.completedOnboardingForCurrentSession
            return .onboarding(complete: {
                completedOnboardingForCurrentSession.value = true
            }, openURL: application.open)
        case .authorizationRequired:
            return .authorizationRequired(requestPermissions: requestPermissions, country: country)
        case .canNotRunExposureNotification(let reason):
            return .canNotRunExposureNotification(reason: disabledReason(from: reason), country: country.currentValue)
        case .postcodeRequired:
            return .postcodeRequired(savePostcode: savePostcode)
        case .fullyOnboarded:
            let isolationStateStore = self.isolationStateStore
            
            return .runningExposureNotification(
                RunningAppContext(
                    checkInContext: checkInContext,
                    postcodeInfo: postcodeInfo ?? .constant(nil),
                    savePostcode: savePostcode,
                    country: country,
                    openSettings: application.openSettings,
                    openURL: application.open,
                    selfDiagnosisManager: selfDiagnosisManager,
                    isolationState: isolationStateManager.$state
                        .map(IsolationState.init)
                        .domainProperty(),
                    testInfo: isolationStateStore.$isolationStateInfo.map { $0?.isolationInfo.indexCaseInfo?.testInfo }.domainProperty(),
                    isolationAcknowledgementState: isolationStateManager.$state
                        .combineLatest(notificationCenter.onApplicationBecameActive, notificationCenter.today) { state, _, _ in state }
                        .map {
                            IsolationAcknowledgementState(
                                logicalState: $0,
                                now: self.currentDateProvider(),
                                acknowledgeStart: isolationStateStore.acknowldegeStartOfIsolation,
                                acknowledgeEnd: isolationStateStore.acknowldegeEndOfIsolation
                            )
                        }
                        .removeDuplicates(by: { (currentState, newState) -> Bool in
                            switch (currentState, newState) {
                            case (.notNeeded, .notNeeded): return true
                            case (.neededForEnd(let isolation1, _), .neededForEnd(let isolation2, _)): return isolation1 == isolation2
                            case (.neededForStart(let isolation1, _), .neededForStart(let isolation2, _)): return isolation1 == isolation2
                            default: return false
                            }
                        })
                        .eraseToAnyPublisher(),
                    exposureNotificationStateController: exposureNotificationStateController,
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
                    appReviewPresenter: appReviewPresenter,
                    stopSelfIsolation: isolationStateStore.stopSelfIsolation
                )
            )
        }
    }
    
    private func makeRiskyCheckInsAcknowledgementState() -> AnyPublisher<RiskyCheckInsAcknowledgementState, Never> {
        guard let checkInContext = self.checkInContext else {
            return Just(.notNeeded).eraseToAnyPublisher()
        }
        
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
                    return self.exposureDetectionManager.sendKeys(
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
            .combineLatest(isolationStateStore.$isolationStateInfo, notificationCenter.today)
            .map { [weak self] result, isolationStateInfo, _ in
                guard let self = self, let result = result else {
                    return TestResultAcknowledgementState.notNeeded
                }
                
                let newIsolationStateInfo = self.isolationStateStore.newIsolationStateInfo(
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
                    
                    self.isolationStateStore.isolationStateInfo = newIsolationStateInfo
                    
                    if !newIsolationState.isIsolating {
                        self.isolationStateStore.acknowldegeEndOfIsolation()
                    }
                    
                    if !currentIsolationState.isIsolating, newIsolationState.isIsolating {
                        self.isolationStateStore.restartIsolationAcknowledgement()
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
        var hasPostcode: AnyPublisher<Bool, Never>
        if let postcodeStore = postcodeStore {
            hasPostcode = postcodeStore.$hasPostcode.eraseToAnyPublisher()
        } else {
            hasPostcode = Just(true).eraseToAnyPublisher()
        }
        
        var isActivated: AnyPublisher<Bool, Never>
        
        if let appActivationManager = appActivationManager {
            isActivated = appActivationManager.$isActivated.eraseToAnyPublisher()
        } else {
            isActivated = Just(true).eraseToAnyPublisher()
        }
        
        return isActivated
            .combineLatest(appAvailabilityManager.$state, completedOnboardingForCurrentSession)
            .combineLatest(exposureNotificationStateController.combinedState, userNotificationsStateController.$authorizationStatus, hasPostcode)
            .map { f in
                RawState(
                    isAppActivated: f.0.0,
                    appAvailability: f.0.1,
                    completedOnboardingForCurrentSession: f.0.2,
                    exposureState: f.1,
                    userNotificationsStatus: f.2,
                    hasPostcode: f.3
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
        case .runningExposureNotification where postcodeStore != nil && riskyPostcodeEndpointManager?.isEmpty ?? false:
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
        let exposureDetectionManager = self.exposureDetectionManager
        let riskScoreNegotiator = self.riskScoreNegotiator
        let handleDontWorryNotification = self.handleDontWorryNotification
        let expsoureNotificationJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.exposureDetectionBackgroundTaskFrequency
        ) {
            exposureDetectionManager.detectExposures(currentDate: self.currentDateProvider())
                .filterNil()
                .map { riskInfo in
                    let riskHandled = riskScoreNegotiator.saveIfNeeded(exposureRiskInfo: riskInfo)
                    if !riskHandled {
                        handleDontWorryNotification()
                    } else {
                        circuitBreaker.showDontWorryNotificationIfNeeded = true
                    }
                }
                .append(Deferred(createPublisher: circuitBreaker.processExposureNotificationApproval))
                .eraseToAnyPublisher()
        }
        enabledJobs.append(expsoureNotificationJob)
        
        let riskyPostcodeEndpointManager = self.riskyPostcodeEndpointManager
        if let riskyPostcodeEndpointManager = riskyPostcodeEndpointManager {
            let postcodeJob = BackgroundTaskAggregator.Job(
                preferredFrequency: Self.exposureDetectionBackgroundTaskFrequency,
                work: riskyPostcodeEndpointManager.update
            )
            enabledJobs.append(postcodeJob)
        }
        
        if let checkInContext = self.checkInContext {
            let deleteExpiredCheckInJob = BackgroundTaskAggregator.Job(
                preferredFrequency: Self.expiredCheckInsDeletionBackgroundTaskFrequency,
                work: checkInContext.checkInsManager.deleteExpiredCheckIns
            )
            enabledJobs.append(deleteExpiredCheckInJob)
            
            let matchRiskyVenuesJob = BackgroundTaskAggregator.Job(
                preferredFrequency: Self.matchingRiskyVenuesDeletionBackgroundTaskFrequency
            ) {
                checkInContext.checkInsManager.evaluateVenuesRisk()
                    .append(Deferred(createPublisher: circuitBreaker.processRiskyVenueApproval))
                    .eraseToAnyPublisher()
            }
            enabledJobs.append(matchRiskyVenuesJob)
        }
        
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
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.metricsJobBackgroundTaskFrequency,
                work: isolationStateStore.recordMetrics
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.metricsJobBackgroundTaskFrequency,
                work: isolationStateManager.recordMetrics
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.housekeepingJobBackgroundTaskFrequency,
                work: isolationConfiguration.update
            )
        )
        
        enabledJobs.append(
            BackgroundTaskAggregator.Job(
                preferredFrequency: Self.housekeepingJobBackgroundTaskFrequency,
                work: exposureNotificationStateController.recordMetrics
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
        
        if let postcodeInfo = postcodeInfo {
            let risk = postcodeInfo
                .compactMap { $0?.risk }
                .switchToLatest()
                .map { $0?.id }
                .filterNil()
            
            changeNotifier
                .alertUserToChanges(in: risk, type: .postcode)
                .store(in: &cancellabes)
        }
        
        if let checkInContext = checkInContext {
            RiskyCheckInsChangeNotifier(notificationManager: userNotificationsManager)
                .alertUserToChanges(in: checkInContext.checkInsStore.$unacknowledgedRiskyCheckIns)
                .store(in: &cancellabes)
        }
        
        changeNotifier
            .alertUserToChanges(in: appAvailabilityManager.$state, type: .appAvailability)
            .store(in: &cancellabes)
        
        IsolationStateChangeNotifier(notificationManager: userNotificationsManager)
            .alertUserToChanges(in: isolationStateManager.$state)
            .store(in: &cancellabes)
    }
    
    private func requestPermissions() {
        exposureNotificationStateController.enable {
            self.userNotificationsStateController.authorize()
            self.metricRecoder.didFinishOnboarding()
        }
    }
    
    public func handleUserNotificationAction(_ action: UserNotificationAction, completion: @escaping () -> Void) {
        switch action {
        case .enableExposureNotification:
            exposureNotificationStateController.enable(completion: completion)
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
        postcodeStore?.delete()
        checkInContext?.checkInsStore.deleteAll()
        isolationStateStore.isolationStateInfo = nil
        exposureDetectionStore.delete()
        virologyTestingStateStore.delete()
    }
    
    private func deleteCheckIn(with id: String) {
        checkInContext?.checkInsStore.delete(checkInId: id)
    }
    
}

private extension NotificationCenter {
    
    var onApplicationBecameActive: AnyPublisher<Void, Never> {
        publisher(for: UIApplication.didBecomeActiveNotification)
            .map { _ in () }
            .prepend(())
            .eraseToAnyPublisher()
    }
    
}
