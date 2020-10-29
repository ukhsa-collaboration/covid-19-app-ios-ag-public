//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation
import UIKit

struct IsolationContext {
    let isolationStateStore: IsolationStateStore
    let isolationStateManager: IsolationStateManager
    let isolationConfiguration: CachedResponse<IsolationConfiguration>
    
    private let notificationCenter: NotificationCenter
    private let currentDateProvider: () -> Date
    
    init(
        isolationConfiguration: CachedResponse<IsolationConfiguration>,
        encryptedStore: EncryptedStoring,
        notificationCenter: NotificationCenter,
        currentDateProvider: @escaping () -> Date
    ) {
        self.isolationConfiguration = isolationConfiguration
        self.notificationCenter = notificationCenter
        self.currentDateProvider = currentDateProvider
        
        isolationStateStore = IsolationStateStore(store: encryptedStore) { isolationConfiguration.value }
        isolationStateManager = IsolationStateManager(stateStore: isolationStateStore, notificationCenter: notificationCenter)
    }
    
    func makeIsolationAcknowledgementState() -> AnyPublisher<IsolationAcknowledgementState, Never> {
        isolationStateManager.$state
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
