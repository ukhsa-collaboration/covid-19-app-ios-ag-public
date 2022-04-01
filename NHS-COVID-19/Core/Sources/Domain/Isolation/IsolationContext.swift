//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import UIKit

struct IsolationContext {
    
    struct AcknowledgementCompletionActions {
        var shouldSuggestBookingFollowUpTest: Bool
        var shouldAllowKeySubmission: Bool
    }
    
    let isolationStateStore: IsolationStateStore
    let isolationStateManager: IsolationStateManager
    let isolationConfiguration: CachedResponse<EnglandAndWalesIsolationConfigurations>
    let country: DomainProperty<Country>
    
    private let notificationCenter: NotificationCenter
    private let currentDateProvider: DateProviding
    private let removeExposureDetectionNotifications: () -> Void
    
    let shouldAskForSymptoms = CurrentValueSubject<Bool, Never>(false)
    
    init(
        isolationConfiguration: CachedResponse<EnglandAndWalesIsolationConfigurations>,
        encryptedStore: EncryptedStoring,
        notificationCenter: NotificationCenter,
        currentDateProvider: DateProviding,
        removeExposureDetectionNotifications: @escaping () -> Void,
        country: DomainProperty<Country>
    ) {
        self.isolationConfiguration = isolationConfiguration
        self.notificationCenter = notificationCenter
        self.currentDateProvider = currentDateProvider
        self.removeExposureDetectionNotifications = removeExposureDetectionNotifications
        self.country = country
        
        isolationStateStore = IsolationStateStore(
            store: encryptedStore,
            latestConfiguration: { isolationConfiguration.value.for(country.currentValue) },
            currentDateProvider: currentDateProvider
        )
        isolationStateManager = IsolationStateManager(stateStore: isolationStateStore, currentDateProvider: currentDateProvider)
    }
    
    func canBookALabTest() -> AnyPublisher<Bool, Never> {
        isolationStateManager.$state
            .combineLatest(isolationConfiguration.$value, country)
            .map { state, configuration, country in
                switch state {
                case .isolating:
                    return true
                case .notIsolating(let isolation):
                    return showOptOutLabTestBooking(isolation: isolation, duration: configuration.for(country).contactCase)
                case .isolationFinishedButNotAcknowledged(let isolation):
                    return showOptOutLabTestBooking(isolation: isolation, duration: configuration.for(country).contactCase)
                }
            }.eraseToAnyPublisher()
    }
    
    private func showOptOutLabTestBooking(isolation: Isolation?, duration: DayDuration) -> Bool {
        guard let isolation = isolation else { return false }
        
        if let optOutOfContactIsolationInfo = isolation.optOutOfContactIsolationInfo {
            return optOutOfContactIsolationInfo.untilStartOfDay > currentDateProvider.currentLocalDay
        } else {
            return false
        }
    }
    
    func makeIsolationAcknowledgementState() -> AnyPublisher<IsolationAcknowledgementState, Never> {
        isolationStateManager.$state
            .combineLatest(notificationCenter.onApplicationBecameActive, currentDateProvider.today) { state, _, _ in state }
            .map { state in
                IsolationAcknowledgementState(
                    logicalState: state,
                    now: self.currentDateProvider.currentDate,
                    acknowledgeStart: { hasOptedOut in
                        isolationStateStore.acknowldegeStartOfIsolation()
                        if hasOptedOut {
                            optOutContactIsolationOnExposurerDay()
                        }
                        removeExposureDetectionNotifications()
                        Metrics.signpost(.acknowledgedStartOfIsolationDueToRiskyContact)
                    },
                    acknowledgeEnd: isolationStateStore.acknowldegeEndOfIsolation
                )
            }
            .removeDuplicates(by: { (currentState, newState) -> Bool in
                switch (currentState, newState) {
                case (.notNeeded, .notNeeded): return true
                case (.neededForEnd(let isolation1, _), .neededForEnd(let isolation2, _)): return isolation1 == isolation2
                case (.neededForStartContactIsolation(let isolation1, _), .neededForStartContactIsolation(let isolation2, _)): return isolation1 == isolation2
                default: return false
                }
            })
            .eraseToAnyPublisher()
    }
    
    func makeResultAcknowledgementState(
        result: VirologyStateTestResult?,
        completionHandler: @escaping (AcknowledgementCompletionActions) -> Void
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
                
                return TestResultAcknowledgementState(
                    result: result,
                    newIsolationState: newIsolationState,
                    currentIsolationState: currentIsolationState,
                    indexCaseInfo: newIsolationStateInfo.isolationInfo.indexCaseInfo
                ) {
                    testResultMetricsHandler.trackMetrics()
                    
                    isolationStateStore.isolationStateInfo = newIsolationStateInfo
                    
                    if !newIsolationState.isIsolating {
                        isolationStateStore.acknowldegeEndOfIsolation()
                    }
                    
                    if !currentIsolationState.isIsolating, newIsolationState.isIsolating {
                        isolationStateStore.restartIsolationAcknowledgement()
                    }
                    
                    let shouldSuggestBookingFollowUpTest: Bool = {
                        if case .isolating(let isolation, _, _) = currentIsolationState,
                            result.requiresConfirmatoryTest,
                            isolation.hasConfirmedPositiveTestResult {
                            return false
                        } else if newIsolationState.isIsolating, result.requiresConfirmatoryTest {
                            return storeOperation != .overwriteAndComplete
                        } else {
                            return false
                        }
                    }()
                    
                    completionHandler(
                        AcknowledgementCompletionActions(
                            shouldSuggestBookingFollowUpTest: shouldSuggestBookingFollowUpTest && result.shouldOfferFollowUpTest,
                            shouldAllowKeySubmission: storeOperation != .ignore
                        )
                    )
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
    
    func optOutContactIsolationOnExposurerDay() {
        guard let contactCaseInfo = isolationStateStore.isolationInfo.contactCaseInfo else {
            return // assert? - invalid state...
        }
        optOutContactIsolation(optOutDay: contactCaseInfo.exposureDay)
    }
    
    private func optOutContactIsolation(optOutDay: GregorianDay) {
        guard let contactCaseInfo = isolationStateStore.isolationInfo.contactCaseInfo,
            let activeIsolation = isolationStateManager.isolationLogicalState.currentValue.activeIsolation else {
            return // assert? - invalid state...
        }
        
        let isContactCaseOnly = activeIsolation.isContactCaseOnly
        
        let updatedContactCase = mutating(contactCaseInfo) {
            $0.optOutOfIsolationDay = optOutDay
        }
        isolationStateStore.set(updatedContactCase)
        
        if isContactCaseOnly {
            isolationStateStore.acknowldegeEndOfIsolation()
        }
        
        Metrics.signpost(.optedOutForContactIsolation)
    }
    
    func handleSymptomsIsolationState(onsetDay: GregorianDay?) -> (IsolationState, SelfDiagnosisEvaluation.ExistingPositiveTestState) {
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
                return (isolationState, .hasTest(shouldChangeAdviceDueToSymptoms: true))
            } else {
                let isolationState = IsolationState(logicalState: currentIsolationLogicalState)
                return (isolationState, .hasTest(shouldChangeAdviceDueToSymptoms: false))
            }
        } else {
            let info = IndexCaseInfo(
                symptomaticInfo: symptomaticInfo,
                testInfo: nil
            )
            let newIsolationLogicalState = isolationStateStore.set(info)
            let isolationState = IsolationState(logicalState: newIsolationLogicalState)
            return (isolationState, .hasNoTest)
        }
    }
    
    func handleContactCase(riskInfo: RiskInfo, sendContactCaseIsolationNotification: @escaping () -> Void) {
        let contactCaseInfo = ContactCaseInfo(exposureDay: riskInfo.day, isolationFromStartOfDay: currentDateProvider.currentGregorianDay(timeZone: .current))
        isolationStateStore.set(contactCaseInfo)
        sendContactCaseIsolationNotification()
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

extension EnglandAndWalesIsolationConfigurations {
    func `for`(_ country: Country) -> IsolationConfiguration {
        switch country {
        case .england:
            return england
        case .wales:
            return wales
        }
    }
}
