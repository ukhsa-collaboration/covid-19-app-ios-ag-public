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
    
    private static let logger = Logger(label: "ApplicationCoordinator")
    
    private let application: Application
    private let appAvailabilityManager: AppAvailabilityManager
    private let appActivationManager: AppActivationManager
    private let metricRecoder: MetricReporter
    private let exposureNotificationStateController: ExposureNotificationStateController
    private let userNotificationsStateController: UserNotificationsStateController
    private var cancellabes = [AnyCancellable]()
    private let exposureNotificationManager: ExposureNotificationManaging
    private let processingTaskRequestManager: ProcessingTaskRequestManaging
    private var backgroundTaskAggregator: BackgroundTaskAggregator?
    private let postcodeStore: PostcodeStore?
    private let exposureDetectionStore: ExposureDetectionStore
    private let postcodeManager: PostcodeManager?
    private let detectionExposureManager: DetectionExposureManager
    private let distributeClient: HTTPClient
    private let selfDiagnosisManager: SelfDiagnosisManager?
    private let checkInContext: CheckInContext?
    private let isolationStateStore: IsolationStateStore
    private let isolationStateManager: IsolationStateManager
    private let isolationConfiguration: CachedResponse<IsolationConfiguration>
    private let notificationCenter: NotificationCenter
    private let virologyTestingManager: VirologyTestingManager
    private let virologyTestingStateStore: VirologyTestingStateStore
    private let riskScoreNegotiator: RiskScoreNegotiator
    private let circuitBreaker: CircuitBreaker
    private let housekeeper: Housekeeper
    private let qrCodeScanner: QRCodeScanning
    
    public let pasteboardCopier: PasteboardCopying
    
    @Published
    public var state = ApplicationState.starting
    
    public init(services: ApplicationServices, enabledFeatures: [Feature]) {
        application = services.application
        notificationCenter = services.notificationCenter
        processingTaskRequestManager = services.processingTaskRequestManager
        exposureNotificationManager = services.exposureNotificationManager
        distributeClient = services.distributeClient
        pasteboardCopier = services.pasteboardCopier
        
        Self.logger.debug("Initialising")
        
        appAvailabilityManager = AppAvailabilityManager(
            distributeClient: distributeClient,
            iTunesClient: services.iTunesClient,
            cacheStorage: services.cacheStorage,
            appInfo: services.appInfo
        )
        
        appActivationManager = AppActivationManager(store: services.encryptedStore, httpClient: services.apiClient)
        
        if enabledFeatures.contains(.riskyPostcode) {
            postcodeStore = PostcodeStore(store: services.encryptedStore, isValid: services.postcodeValidator.isValid(_:))
            postcodeManager = PostcodeManager(postcodeStore: postcodeStore!, httpClient: distributeClient)
        } else {
            postcodeManager = nil
            postcodeStore = nil
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
                let info = IndexCaseInfo(selfDiagnosisDay: .today, onsetDay: onsetDay, testInfo: nil)
                return IsolationState(logicalState: isolationStateStore.set(info))
            }
        } else {
            selfDiagnosisManager = nil
        }
        
        if enabledFeatures.contains(.venueCheckIn) {
            let checkInsStore = CheckInsStore(store: services.encryptedStore, venueDecoder: services.venueDecoder)
            checkInContext = CheckInContext(
                cameraStateController: CameraStateController(
                    manager: services.cameraManager,
                    notificationCenter: notificationCenter
                ),
                checkInsStore: checkInsStore,
                checkInsManager: CheckInsManager(checkInsStore: checkInsStore, httpClient: distributeClient)
            )
        } else {
            checkInContext = nil
        }
        
        exposureDetectionStore = ExposureDetectionStore(store: services.encryptedStore)
        
        virologyTestingStateStore = VirologyTestingStateStore(store: services.encryptedStore)
        virologyTestingManager = VirologyTestingManager(
            httpClient: services.apiClient,
            virologyTestingStateStore: virologyTestingStateStore,
            userNotificationsManager: services.userNotificationsManager,
            updateIsolationState: isolationStateStore.set
        )
        
        let isolationStateManager = self.isolationStateManager
        detectionExposureManager = DetectionExposureManager(
            manager: exposureNotificationManager,
            distributionClient: distributeClient,
            submissionClient: services.apiClient,
            encryptedStore: services.encryptedStore,
            interestedInExposureNotifications: { isolationStateManager.state.isolation?.interestedInExposureNotifications ?? true }
        )
        
        exposureNotificationStateController = ExposureNotificationStateController(manager: exposureNotificationManager)
        exposureNotificationStateController.activate()
        
        userNotificationsStateController = UserNotificationsStateController(
            manager: services.userNotificationsManager,
            notificationCenter: notificationCenter
        )
        
        let postcodeStore = self.postcodeStore
        metricRecoder = MetricReporter(manager: services.metricManager, client: services.apiClient, encryptedStore: services.encryptedStore) {
            postcodeStore?.load() ?? ""
        }
        
        riskScoreNegotiator = RiskScoreNegotiator(
            isolationStateManager: isolationStateManager,
            exposureDetectionStore: exposureDetectionStore
        )
        
        riskScoreNegotiator
            .deleteRiskIfIsolating()
            .store(in: &cancellabes)
        
        circuitBreaker = CircuitBreaker(
            client: CircuitBreakerClient(httpClient: services.apiClient),
            exposureInfoProvider: exposureDetectionStore,
            riskyCheckinsProvider: checkInContext?.checkInsStore ?? NoOpRiskyCheckinsProvider(),
            handleContactCase: { riskInfo in
                let contactCaseInfo = ContactCaseInfo(exposureDay: riskInfo.day, isolationFromStartOfDay: .today)
                isolationStateStore.set(contactCaseInfo)
                services.userNotificationsManager.add(type: .exposureDetection, at: nil, withCompletionHandler: nil)
            }
        )
        
        housekeeper = Housekeeper(
            isolationStateStore: isolationStateStore,
            isolationStateManager: isolationStateManager,
            virologyTestingStateStore: virologyTestingStateStore
        )
        
        qrCodeScanner = QRCodeScanner(cameraManager: services.cameraManager)
        
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
            return .pilotActivationRequired(submit: appActivationManager.activate(with:))
        case .failedToStart:
            return .failedToStart
        case .authorizationOnboarding:
            return .authorizationOnboarding(requestPermissions: requestPermissions, openURL: application.open)
        case .canNotRunExposureNotification(let reason):
            return .canNotRunExposureNotification(reason: disabledReason(from: reason))
        case .postcodeOnboarding:
            return .postcodeOnboarding(savePostcode: postcodeStore?.save ?? { _ in })
        case .fullyOnboarded:
            let isolationStateStore = self.isolationStateStore
            return .runningExposureNotification(
                RunningAppContext(
                    checkInContext: checkInContext,
                    postcodeStore: postcodeStore,
                    openSettings: application.openSettings,
                    openURL: application.open,
                    selfDiagnosisManager: selfDiagnosisManager,
                    isolationState: isolationStateManager.$state
                        .map(IsolationState.init)
                        .domainProperty(),
                    testInfo: isolationStateStore.$isolationStateInfo.map { $0?.isolationInfo.indexCaseInfo?.testInfo }.domainProperty(),
                    isolationAcknowledgementState: isolationStateManager.$state
                        .combineLatest(notificationCenter.onApplicationBecameActive) { state, _ in state }
                        .map {
                            IsolationAcknowledgementState(
                                logicalState: $0, now: Date(),
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
                    virologyTestOrderInfoProvider: virologyTestingManager,
                    testResultAcknowledgementState: makeResultAcknowledgementState(),
                    symptomsDateAndEncounterDateProvider: isolationStateStore,
                    deleteAllData: { [weak self] in
                        self?.deleteAllData()
                    },
                    riskyCheckInsAcknowledgementState: makeRiskyCheckInsAcknowledgementState(),
                    qrCodeScanner: qrCodeScanner
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
    
    private func positiveAcknowledgement(for token: DiagnosisKeySubmissionToken, endDate: Date) -> TestResultAcknowledgementState.PositiveResultAcknowledgement {
        TestResultAcknowledgementState.PositiveResultAcknowledgement(acknowledge: { [weak self] in
            guard let self = self else { return Empty().eraseToAnyPublisher() }
            
            if let indexCaseInfo = self.isolationStateStore.isolationInfo.indexCaseInfo {
                return self.detectionExposureManager.sendKeys(
                    token: token,
                    onsetDay: indexCaseInfo.onsetDay,
                    selfDiagnosisDay: indexCaseInfo.selfDiagnosisDay,
                    isolationEndDate: endDate
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
                        self.virologyTestingStateStore.removeLatestTestResult()
                    case .failure:
                        break
                    }
                })
                .eraseToAnyPublisher()
            } else {
                self.virologyTestingStateStore.removeLatestTestResult()
                return Result.success(()).publisher.eraseToAnyPublisher()
            }
        }, acknowledgeWithoutSending: { [weak self] in
            self?.virologyTestingStateStore.removeLatestTestResult()
        })
    }
    
    private func makeResultAcknowledgementState() -> AnyPublisher<TestResultAcknowledgementState, Never> {
        virologyTestingStateStore.$virologyTestResult
            .combineLatest(isolationStateManager.$state)
            .map { [weak self] result, isolationState in
                guard let self = self, let result = result else {
                    return TestResultAcknowledgementState.notNeeded
                }
                
                switch (result.testResult, isolationState) {
                case (.positive, .isolating(let isolation, _, _)):
                    guard let diagnosisKeySubmissionToken = result.diagnosisKeySubmissionToken else {
                        return TestResultAcknowledgementState.notNeeded
                    }
                    return TestResultAcknowledgementState.neededForPositiveResult(
                        self.positiveAcknowledgement(for: diagnosisKeySubmissionToken, endDate: isolation.endDate),
                        isolationEndDate: isolation.endDate
                    )
                case (.positive, _):
                    guard let diagnosisKeySubmissionToken = result.diagnosisKeySubmissionToken else {
                        return TestResultAcknowledgementState.notNeeded
                    }
                    let endDate = self.isolationStateStore.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay.startDate(in: .current)
                    return TestResultAcknowledgementState.neededForPositiveResultNoIsolation(
                        self.positiveAcknowledgement(for: diagnosisKeySubmissionToken, endDate: endDate ?? Date())
                    )
                case (.negative, .isolating(let isolation, _, _)):
                    return TestResultAcknowledgementState.neededForNegativeResult(
                        acknowledge: { self.virologyTestingStateStore.removeLatestTestResult() },
                        isolationEndDate: isolation.endDate
                    )
                case (.negative, _):
                    return TestResultAcknowledgementState.neededForNegativeResultNoIsolation(
                        acknowledge: {
                            self.virologyTestingStateStore.removeLatestTestResult()
                            self.isolationStateStore.acknowldegeEndOfIsolation()
                        }
                    )
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
        
        return appActivationManager.$isActivated
            .combineLatest(appAvailabilityManager.$state)
            .combineLatest(exposureNotificationStateController.combinedState, userNotificationsStateController.$authorizationStatus, hasPostcode)
            .map { f in
                RawState(isAppActivated: f.0.0, appAvailability: f.0.1, exposureState: f.1, userNotificationsStatus: f.2, hasPostcode: f.3)
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
        case .runningExposureNotification where postcodeStore != nil && postcodeStore?.riskLevel == nil:
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
        let detectionExposureManager = self.detectionExposureManager
        let riskScoreNegotiator = self.riskScoreNegotiator
        let expsoureNotificationJob = BackgroundTaskAggregator.Job(
            preferredFrequency: Self.exposureDetectionBackgroundTaskFrequency
        ) {
            detectionExposureManager.detectExposures()
                .filterNil()
                .map { riskInfo in
                    riskScoreNegotiator.receive(riskInfo: riskInfo)
                }
                .append(Deferred(createPublisher: circuitBreaker.processExposureNotificationApproval))
                .eraseToAnyPublisher()
        }
        enabledJobs.append(expsoureNotificationJob)
        
        if let postcodeManager = self.postcodeManager {
            let postcodeJob = BackgroundTaskAggregator.Job(
                preferredFrequency: Self.exposureDetectionBackgroundTaskFrequency
            ) {
                postcodeManager.evaluatePostcodeRisk()
                    .append(Deferred(createPublisher: circuitBreaker.processRiskyVenueApproval))
                    .eraseToAnyPublisher()
            }
            enabledJobs.append(postcodeJob)
        }
        
        if let checkInContext = self.checkInContext {
            let deleteExpiredCheckInJob = BackgroundTaskAggregator.Job(
                preferredFrequency: Self.expiredCheckInsDeletionBackgroundTaskFrequency,
                work: checkInContext.checkInsManager.deleteExpiredCheckIns
            )
            enabledJobs.append(deleteExpiredCheckInJob)
            
            let matchRiskyVenuesJob = BackgroundTaskAggregator.Job(
                preferredFrequency: Self.matchingRiskyVenuesDeletionBackgroundTaskFrequency,
                work: checkInContext.checkInsManager.evaluateVenuesRisk
            )
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
        
        return enabledJobs
    }
    
    private func setupChangeNotifiers(using userNotificationsManager: UserNotificationManaging) {
        let changeNotifier = ChangeNotifier(notificationManager: userNotificationsManager)
        
        if let postcodeStore = postcodeStore {
            changeNotifier
                .alertUserToChanges(in: postcodeStore.$riskLevel, type: .postcode) { $0 != nil }
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
        // start with postcode. This resets the UI immediately; making sure there’s no jitter as we delete everything
        postcodeStore?.delete()
        checkInContext?.checkInsStore.deleteAll()
        isolationStateStore.isolationStateInfo = nil
        exposureDetectionStore.delete()
        virologyTestingStateStore.delete()
    }
}

private extension NotificationCenter {
    
    var onApplicationBecameActive: AnyPublisher<Date, Never> {
        publisher(for: UIApplication.didBecomeActiveNotification)
            .map { _ in Date() }
            .prepend(Date())
            .eraseToAnyPublisher()
    }
    
}
