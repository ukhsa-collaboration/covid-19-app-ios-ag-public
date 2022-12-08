//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import ExposureNotification

public protocol SelfReportingManaging {
    func getDiagnosisKeys() -> AnyPublisher<[ENTemporaryExposureKey], Error>
    func submit(testResult: TestResult, testKitType: TestKitType, testDate: GregorianDay, symptoms: Bool, onsetDay: GregorianDay?, nhsTest: Bool?, reportedResult: Bool?)
    func share(keys: Result<[ENTemporaryExposureKey], Error>, completion: @escaping  (Result<DiagnosisKeySharer.ShareResult, Error>) -> Void)
    func doNotShareKeys()
    func recordNegativeTestResultMetrics()
    func recordVoidTestResultMetrics()
    var alreadyInIsolation: Bool { get }
}

public enum SelfReportingShareResult {
    case sent
    case notSent
}

class SelfReportingManager: SelfReportingManaging {
    public var manager: ExposureNotificationManaging

    private let virologyTestingStateStore: VirologyTestingStateStore
    private let isolationStateStore: IsolationStateStore
    private let currentDateProvider: DateProviding
    private let keySharingStore: KeySharingStore
    private let exposureNotificationContext: ExposureNotificationContext
    private let diagnosisKeySharer: DomainProperty<DiagnosisKeySharer?>
    private let trafficObfuscationClient: TrafficObfuscationClient

    private var shareKeysCancellable: AnyCancellable? = nil

    init(
        manager: ExposureNotificationManaging,
        virologyTestingStateStore: VirologyTestingStateStore,
        isolationStateStore: IsolationStateStore,
        currentDateProvider: DateProviding,
        keySharingStore: KeySharingStore,
        exposureNotificationContext: ExposureNotificationContext,
        diagnosisKeySharer: DomainProperty<DiagnosisKeySharer?>,
        trafficObfuscationClient: TrafficObfuscationClient
    ) {
        self.manager = manager
        self.virologyTestingStateStore = virologyTestingStateStore
        self.isolationStateStore = isolationStateStore
        self.currentDateProvider = currentDateProvider
        self.keySharingStore = keySharingStore
        self.exposureNotificationContext = exposureNotificationContext
        self.diagnosisKeySharer = diagnosisKeySharer
        self.trafficObfuscationClient = trafficObfuscationClient
    }

    var alreadyInIsolation: Bool {
        let isolationLogicalState = IsolationLogicalState(stateInfo: isolationStateStore.isolationStateInfo, day: currentDateProvider.currentLocalDay)
        return isolationLogicalState.isIsolating
    }

    func getDiagnosisKeys() -> AnyPublisher<[ENTemporaryExposureKey], Error> {
        Future { [weak self] promise in
            self?.manager.getDiagnosisKeys { keys, error in
                if let error = error {
                    promise(.failure(error))
                }
                if let keys = keys {
                    promise(.success(keys))
                }
            }
        }.eraseToAnyPublisher()
    }

    func submit(testResult: TestResult, testKitType: TestKitType, testDate: GregorianDay, symptoms: Bool, onsetDay: GregorianDay?, nhsTest: Bool?, reportedResult: Bool?) {
        let virologyTestResult = VirologyTestResult(
            testResult: testResult == .positive ? .positive : .negative,
            testKitType: testKitType == .labResult ? .labResult : .rapidSelfReported,
            endDate: testDate.startDate(in: .utc)
        )

        Metrics.signpost(.completedSelfReportingTestFlow)

        if nhsTest == true {
            Metrics.signpost(.isPositiveSelfLFDFree)
        }

        if reportedResult == true {
            Metrics.signpost(.selfReportedPositiveSelfLFDOnGov)
        }

        Metrics.signpostReceivedFromManual(
            testResult: virologyTestResult.testResult,
            testKitType: virologyTestResult.testKitType,
            requiresConfirmatoryTest: false
        )

        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .defaultDiagnosisKeySubmissionToken()),
            requiresConfirmatoryTest: false,
            shouldOfferFollowUpTest: false,
            confirmatoryDayLimit: nil
        )

        isolate(symptoms: symptoms, onsetDay: onsetDay)
    }

    private func isolate(symptoms: Bool, onsetDay: GregorianDay?) {
        if let result = virologyTestingStateStore.virologyTestResult.currentValue {

            var didRememberOnsetSymptomsDateBeforeReceivedTestResult = false
            if symptoms {
                Metrics.signpost(.didHaveSymptomsBeforeReceivedTestResult)
                if let onsetDay = onsetDay {
                    let info = IndexCaseInfo(
                        symptomaticInfo: IndexCaseInfo.SymptomaticInfo(
                            selfDiagnosisDay: currentDateProvider.currentGregorianDay(timeZone: .utc),
                            onsetDay: onsetDay),
                        testInfo: nil
                    )
                    didRememberOnsetSymptomsDateBeforeReceivedTestResult = true
                    isolationStateStore.set(info)
                    Metrics.signpost(.didRememberOnsetSymptomsDateBeforeReceivedTestResult)
                }
            }

            let isolationStateInfo = isolationStateStore.isolationStateInfo

            let currentIsolationState = didRememberOnsetSymptomsDateBeforeReceivedTestResult
            ? .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
            : IsolationLogicalState(stateInfo: isolationStateInfo, day: self.currentDateProvider.currentLocalDay)

            let testResultIsolationOperation = TestResultIsolationOperation(
                currentIsolationState: currentIsolationState,
                storedIsolationInfo: isolationStateInfo?.isolationInfo,
                result: result,
                configuration: isolationStateStore.configuration,
                currentDateProvider: currentDateProvider
            )

            let storeOperation = testResultIsolationOperation.storeOperation()
            let newIsolationStateInfo = isolationStateStore.newIsolationStateInfo(
                from: isolationStateInfo?.isolationInfo,
                for: result.testResult,
                testKitType: result.testKitType,
                requiresConfirmatoryTest: result.requiresConfirmatoryTest,
                shouldOfferFollowUpTest: result.shouldOfferFollowUpTest,
                confirmatoryDayLimit: result.confirmatoryDayLimit,
                receivedOn: self.currentDateProvider.currentGregorianDay(timeZone: .current),
                npexDay: result.endDay,
                operation: storeOperation
            )

            let newIsolationState = IsolationLogicalState(stateInfo: newIsolationStateInfo, day: self.currentDateProvider.currentLocalDay)

            let testResultMetricsHandler = TestResultMetricsHandler(
                currentIsolationState: currentIsolationState,
                storedIsolationInfo: isolationStateInfo?.isolationInfo,
                receivedResult: result,
                configuration: isolationStateStore.configuration
            )

            testResultMetricsHandler.trackMetrics()

            isolationStateStore.isolationStateInfo = newIsolationStateInfo

            if !newIsolationState.isIsolating {
                isolationStateStore.acknowldegeEndOfIsolation()
            }

            if !currentIsolationState.isIsolating, newIsolationState.isIsolating {
                isolationStateStore.restartIsolationAcknowledgement()
            }

            acknowledgementCompletion(shouldAllowKeySubmission: storeOperation != .ignore, testKitType: result.testKitType)
        }
    }

    private func acknowledgementCompletion(shouldAllowKeySubmission: Bool, testKitType: TestKitType?) {
        if let virologyTestResult = virologyTestingStateStore.virologyTestResult.currentValue {
            if shouldAllowKeySubmission, let token = virologyTestResult.diagnosisKeySubmissionToken {
                keySharingStore.save(
                    token: token,
                    acknowledgmentTime: UTCHour(containing: self.currentDateProvider.currentDate),
                    hasFinishedInitialKeySharingFlow: true,
                    privateJourney: true,
                    testKitType: testKitType
                )
                Metrics.signpost(.askedToShareExposureKeysInTheInitialFlow)
            } else {
                self.trafficObfuscationClient.sendSingleTraffic(for: TrafficObfuscator.keySubmission)
            }

            virologyTestingStateStore.remove(testResult: virologyTestResult)

            exposureNotificationContext.postExposureWindows(
                result: virologyTestResult.testResult,
                testKitType: virologyTestResult.testKitType,
                requiresConfirmatoryTest: virologyTestResult.requiresConfirmatoryTest
            )
        }
    }

    enum ShareKeysError: Error {
        case diagnosisKeySharerNonExistent
    }

    func share(keys: Result<[ENTemporaryExposureKey], Error>, completion: @escaping (Result<DiagnosisKeySharer.ShareResult, Error>) -> Void) {
        if let diagnosisKeySharer = diagnosisKeySharer.currentValue {
            shareKeysCancellable = diagnosisKeySharer.shareKeys(.initial, keys)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { result in
                    switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }, receiveValue: { result in
                    completion(.success(result))
                })
        } else {
            completion(.failure(ShareKeysError.diagnosisKeySharerNonExistent))
        }
    }

    func doNotShareKeys() {
        if let diagnosisKeySharer = diagnosisKeySharer.currentValue {
            diagnosisKeySharer.doNotShareKeys(.initial)
        }
        shareKeysCancellable = nil
    }

    func recordNegativeTestResultMetrics() {
        Metrics.signpost(.selfReportedNegativeSelfLFDTestResultEnteredManually)
    }

    func recordVoidTestResultMetrics() {
        Metrics.signpost(.selfReportedVoidSelfLFDTestResultEnteredManually)
    }
}
