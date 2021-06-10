//
// Copyright © 2021 DHSC. All rights reserved.
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
    
    var shouldAskForSymptoms = CurrentValueSubject<Bool, Never>(false)
    
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
        completionHandler: @escaping (Bool, Bool) -> Void
    ) -> AnyPublisher<TestResultAcknowledgementState, Never> {
        isolationStateStore.$isolationStateInfo
            .combineLatest(currentDateProvider.today, shouldAskForSymptoms)
            .map { isolationStateInfo, _, shouldAskForSymptoms in
                guard let result = result else {
                    return TestResultAcknowledgementState.notNeeded
                }
                
                if shouldAskForSymptoms {
                    return TestResultAcknowledgementState.askForSymptomsOnsetDay(
                        testEndDay: result.endDay,
                        didFinishAskForSymptomsOnsetDay: {
                            self.shouldAskForSymptoms.send(false)
                        }, didConfirmSymptoms: {
                            Metrics.signpost(.didHaveSymptomsBeforeReceivedTestResult)
                        },
                        setOnsetDay: { onsetDay in
                            let info = IndexCaseInfo(
                                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: currentDateProvider.currentGregorianDay(timeZone: .utc), onsetDay: onsetDay),
                                testInfo: nil
                            )
                            self.isolationStateStore.set(info)
                            Metrics.signpost(.didRememberOnsetSymptomsDateBeforeReceivedTestResult)
                        }
                    )
                }
                
                let currentIsolationState = IsolationLogicalState(stateInfo: isolationStateInfo, day: self.currentDateProvider.currentLocalDay)
                
                let testResultIsolationOperation = TestResultIsolationOperation(
                    currentIsolationState: currentIsolationState,
                    storedIsolationInfo: isolationStateInfo?.isolationInfo,
                    result: result,
                    configuration: isolationStateStore.configuration
                )
                
                let storeOperation = testResultIsolationOperation.storeOperation()
                let newIsolationStateInfo = isolationStateStore.newIsolationStateInfo(
                    from: isolationStateInfo?.isolationInfo,
                    for: result.testResult,
                    testKitType: result.testKitType,
                    requiresConfirmatoryTest: result.requiresConfirmatoryTest,
                    confirmatoryDayLimit: result.confirmatoryDayLimit,
                    receivedOn: self.currentDateProvider.currentGregorianDay(timeZone: .current),
                    npexDay: result.endDay,
                    operation: storeOperation
                )
                
                let newIsolationState = IsolationLogicalState(stateInfo: newIsolationStateInfo, day: self.currentDateProvider.currentLocalDay)
                
                return TestResultAcknowledgementState(
                    result: result,
                    newIsolationState: newIsolationState,
                    currentIsolationState: currentIsolationState,
                    indexCaseInfo: newIsolationStateInfo.isolationInfo.indexCaseInfo
                ) {
                    isolationStateStore.isolationStateInfo = newIsolationStateInfo
                    
                    if !newIsolationState.isIsolating {
                        isolationStateStore.acknowldegeEndOfIsolation()
                    }
                    
                    if !currentIsolationState.isIsolating, newIsolationState.isIsolating {
                        isolationStateStore.restartIsolationAcknowledgement()
                    }
                    
                    if case .isolating(let isolation, _, _) = currentIsolationState,
                        result.requiresConfirmatoryTest,
                        isolation.hasConfirmedPositiveTestResult {
                        completionHandler(storeOperation != .ignore, false)
                    } else if newIsolationState.isIsolating, result.requiresConfirmatoryTest {
                        completionHandler(storeOperation != .ignore, true)
                    } else {
                        completionHandler(storeOperation != .ignore, false)
                    }
                    
                }
            }
            .eraseToAnyPublisher()
    }
    
    func makeBackgroundJobs() -> [BackgroundTaskAggregator.Job] {
        [
            BackgroundTaskAggregator.Job(
                work: isolationStateStore.recordMetrics
            ),
            BackgroundTaskAggregator.Job(
                work: isolationStateManager.recordMetrics
            ),
            BackgroundTaskAggregator.Job(
                work: isolationConfiguration.update
            ),
        ]
    }
    
    var dailyContactTestingEarlyTerminationSupport: DailyContactTestingEarlyIsolationTerminationSupport {
        
        guard let isContactCaseOnly = isolationStateManager.isolationLogicalState.currentValue.activeIsolation?.isContactCaseOnly,
            isContactCaseOnly else {
            return .disabled
        }
        
        return .enabled(optOutOfIsolation: {
            guard let contactCaseInfo = isolationStateStore.isolationInfo.contactCaseInfo else {
                return // assert? - invalid state...
            }
            
            Metrics.signpost(.declaredNegativeResultFromDCT)
            
            let updatedContactCase = mutating(contactCaseInfo) {
                $0.optOutOfIsolationDay = self.currentDateProvider.currentGregorianDay(timeZone: .current)
            }
            self.isolationStateStore.set(updatedContactCase)
            self.isolationStateStore.acknowldegeEndOfIsolation()
        })
    }
    
    #warning("Replace the return value with a more meaningful type")
    func handleSymptomsIsolationState(onsetDay: GregorianDay?) -> (IsolationState, Bool?) {
        let currentIsolationLogicalState = IsolationLogicalState(
            stateInfo: isolationStateStore.isolationStateInfo,
            day: currentDateProvider.currentLocalDay
        )
        let symptomaticInfo = IndexCaseInfo.SymptomaticInfo(
            selfDiagnosisDay: currentDateProvider.currentGregorianDay(timeZone: .current),
            onsetDay: onsetDay
        )
        let hasActivePositiveTestIsolation = currentIsolationLogicalState.activeIsolation?.hasPositiveTestResult ?? false
        
        if hasActivePositiveTestIsolation,
            let currentTestInfo = isolationStateStore.isolationInfo.indexCaseInfo?.testInfo,
            let testEndDay = isolationStateStore.isolationInfo.indexCaseInfo?.assumedTestEndDay {
            let assumedOnsetDay = symptomaticInfo.assumedOnsetDay
            if assumedOnsetDay > testEndDay {
                let info = IndexCaseInfo(
                    symptomaticInfo: symptomaticInfo,
                    testInfo: currentTestInfo
                )
                let newIsolationLogicalState = isolationStateStore.set(info)
                let isolationState = IsolationState(logicalState: newIsolationLogicalState)
                return (isolationState, true)
            } else {
                let isolationState = IsolationState(logicalState: currentIsolationLogicalState)
                return (isolationState, false)
            }
        } else {
            let info = IndexCaseInfo(
                symptomaticInfo: symptomaticInfo,
                testInfo: nil
            )
            let newIsolationLogicalState = isolationStateStore.set(info)
            let isolationState = IsolationState(logicalState: newIsolationLogicalState)
            return (isolationState, nil)
        }
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
