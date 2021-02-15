//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import UIKit

struct IsolationContext {
    let isolationStateStore: IsolationStateStore
    let isolationStateManager: IsolationStateManager
    let isolationConfiguration: CachedResponse<IsolationConfiguration>
    
    private let notificationCenter: NotificationCenter
    private let currentDateProvider: DateProviding
    private let removeExposureDetectionNotifications: () -> Void
    
    init(
        isolationConfiguration: CachedResponse<IsolationConfiguration>,
        encryptedStore: EncryptedStoring,
        notificationCenter: NotificationCenter,
        currentDateProvider: DateProviding,
        removeExposureDetectionNotifications: @escaping () -> Void
    ) {
        self.isolationConfiguration = isolationConfiguration
        self.notificationCenter = notificationCenter
        self.currentDateProvider = currentDateProvider
        self.removeExposureDetectionNotifications = removeExposureDetectionNotifications
        
        isolationStateStore = IsolationStateStore(store: encryptedStore, latestConfiguration: { isolationConfiguration.value }, currentDateProvider: currentDateProvider)
        isolationStateManager = IsolationStateManager(stateStore: isolationStateStore, currentDateProvider: currentDateProvider)
    }
    
    func makeIsolationAcknowledgementState() -> AnyPublisher<IsolationAcknowledgementState, Never> {
        isolationStateManager.$state
            .combineLatest(notificationCenter.onApplicationBecameActive, currentDateProvider.today) { state, _, _ in state }
            .map { state in
                IsolationAcknowledgementState(
                    logicalState: state,
                    now: self.currentDateProvider.currentDate,
                    acknowledgeStart: {
                        isolationStateStore.acknowldegeStartOfIsolation()
                        if state.activeIsolation?.isContactCaseOnly ?? false {
                            removeExposureDetectionNotifications()
                            Metrics.signpost(.acknowledgedStartOfIsolationDueToRiskyContact)
                        }
                    },
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
            .eraseToAnyPublisher()
    }
    
    func makeResultAcknowledgementState(
        result: VirologyStateTestResult?,
        positiveAcknowledgement: @escaping TestResultAcknowledgementState.PositiveAcknowledgement,
        completionHandler: @escaping (TestResultAcknowledgementState.SendKeysState) -> Void
    ) -> AnyPublisher<TestResultAcknowledgementState, Never> {
        isolationStateStore.$isolationStateInfo
            .combineLatest(currentDateProvider.today)
            .map { isolationStateInfo, _ in
                guard let result = result else {
                    return TestResultAcknowledgementState.notNeeded
                }
                let currentIsolationState = IsolationLogicalState(stateInfo: isolationStateInfo, day: self.currentDateProvider.currentLocalDay)
                
                let testResultIsolationOperation = TestResultIsolationOperation(
                    currentIsolationState: currentIsolationState,
                    storedIsolationInfo: self.isolationStateStore.isolationInfo,
                    result: result
                )
                
                let newIsolationStateInfo = isolationStateStore.newIsolationStateInfo(
                    for: result.testResult,
                    testKitType: result.testKitType,
                    requiresConfirmatoryTest: result.requiresConfirmatoryTest,
                    receivedOn: self.currentDateProvider.currentGregorianDay(timeZone: .current),
                    npexDay: GregorianDay(date: result.endDate, timeZone: .utc),
                    operation: testResultIsolationOperation.storeOperation()
                )
                
                let newIsolationState = IsolationLogicalState(stateInfo: newIsolationStateInfo, day: self.currentDateProvider.currentLocalDay)
                
                return TestResultAcknowledgementState(
                    result: result,
                    newIsolationState: newIsolationState,
                    currentIsolationState: currentIsolationState,
                    indexCaseInfo: newIsolationStateInfo.isolationInfo.indexCaseInfo,
                    positiveAcknowledgement: positiveAcknowledgement
                ) { shareKeyState in
                    isolationStateStore.isolationStateInfo = newIsolationStateInfo
                    
                    if !newIsolationState.isIsolating {
                        isolationStateStore.acknowldegeEndOfIsolation()
                    }
                    
                    if !currentIsolationState.isIsolating, newIsolationState.isIsolating {
                        isolationStateStore.restartIsolationAcknowledgement()
                    }
                    
                    completionHandler(shareKeyState)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func makeBackgroundJobs(metricsFrequency: Double, housekeepingFrequency: Double) -> [BackgroundTaskAggregator.Job] {
        [
            BackgroundTaskAggregator.Job(
                preferredFrequency: metricsFrequency,
                work: isolationStateStore.recordMetrics
            ),
            BackgroundTaskAggregator.Job(
                preferredFrequency: metricsFrequency,
                work: isolationStateManager.recordMetrics
            ),
            BackgroundTaskAggregator.Job(
                preferredFrequency: housekeepingFrequency,
                work: isolationConfiguration.update
            ),
        ]
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
