//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks
import Combine
import Foundation
import Logging

class BackgroundTaskAggregator {
    struct Job {
        var preferredFrequency: TimeInterval
        var work: () -> AnyPublisher<Void, Never>
    }
    
    private static let logger = Logger(label: "BackgroundTaskAggregator")
    
    private let manager: ProcessingTaskRequestManaging
    private let jobs: [Job]
    private var cancellables = [AnyCancellable]()
    
    public init(manager: ProcessingTaskRequestManaging, jobs: [Job]) {
        self.manager = manager
        self.jobs = jobs
        
        scheduleNextTaskIfNeeded()
    }
    
    func performBackgroundTask(backgroundTask: BackgroundTask) {
        Self.logger.info("staring background task")
        Metrics.begin(.backgroundTasks)
        
        let cancellable = Publishers.Sequence<[Job], Never>(sequence: jobs)
            .flatMap { $0.work() }
            .collect().eraseToAnyPublisher().sink { [weak self] _ in
                Self.logger.info("background task completed")
                Metrics.end(.backgroundTasks)
                
                self?.scheduleNextTask()
                backgroundTask.setTaskCompleted(success: true)
            }
        
        backgroundTask.expirationHandler = { [weak self] in
            Self.logger.info("background task expired")
            Metrics.end(.backgroundTasks)
            
            cancellable.cancel()
            self?.scheduleNextTask()
        }
        
        cancellable.store(in: &cancellables)
    }
    
    private func scheduleNextTask() {
        guard !jobs.isEmpty else {
            Self.logger.debug("background task not needed")
            return
        }
        
        var request = ProcessingTaskRequest()
        request.requiresNetworkConnectivity = true
        
        let minimumFrequency = jobs.lazy.map { $0.preferredFrequency }.reduce(.infinity, min)
        request.earliestBeginDate = Date(timeIntervalSinceNow: minimumFrequency)
        
        Self.logger.info("scheduling background task", metadata: .describing(request))
        try? manager.submit(request)
    }
    
    private func scheduleNextTaskIfNeeded() {
        manager.getPendingRequest { request in
            if request == nil {
                self.scheduleNextTask()
            } else {
                Self.logger.debug("background task already scheduled")
            }
        }
    }
    
    func stop() {
        manager.cancelPendingRequest()
    }
}
