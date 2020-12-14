//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation
import Common
import UIKit

struct IsolationContext {
    let isolationStateStore: IsolationStateStore
    let isolationStateManager: IsolationStateManager
    let isolationConfiguration: CachedResponse<IsolationConfiguration>
    
    private let notificationCenter: NotificationCenter
    private let currentDateProvider: DateProviding
    
    init(
        isolationConfiguration: CachedResponse<IsolationConfiguration>,
        encryptedStore: EncryptedStoring,
        notificationCenter: NotificationCenter,
        currentDateProvider: DateProviding
    ) {
        self.isolationConfiguration = isolationConfiguration
        self.notificationCenter = notificationCenter
        self.currentDateProvider = currentDateProvider
        
        isolationStateStore = IsolationStateStore(store: encryptedStore, latestConfiguration: { isolationConfiguration.value }, currentDateProvider: currentDateProvider)
        isolationStateManager = IsolationStateManager(stateStore: isolationStateStore, currentDateProvider: currentDateProvider)
    }
    
    func makeIsolationAcknowledgementState() -> AnyPublisher<IsolationAcknowledgementState, Never> {
        isolationStateManager.$state
            .combineLatest(notificationCenter.onApplicationBecameActive, currentDateProvider.today) { state, _, _ in state }
            .map {
                IsolationAcknowledgementState(
                    logicalState: $0,
                    now: self.currentDateProvider.currentDate,
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
            .eraseToAnyPublisher()
    }
    
    func makeBackgroundJobs(metricsFrequency: Double, housekeepingFrequenzy: Double) -> [BackgroundTaskAggregator.Job] {
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
                preferredFrequency: housekeepingFrequenzy,
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
