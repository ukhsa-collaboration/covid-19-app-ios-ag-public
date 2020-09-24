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
            .collect().sink { [weak self] _ in
                Self.logger.info("background task completed")
                Metrics.end(.backgroundTasks)
                
                self?.scheduleNextTask()
                backgroundTask.setTaskCompleted(success: true)
            }
        
        backgroundTask.expirationHandler = { [weak self] in
            Self.logger.info("background task expired")
            Metrics.end(.backgroundTasks)
            
            cancellable.cancel()
            backgroundTask.setTaskCompleted(success: false)
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
            if let request = request {
                Self.logger.debug("background task already scheduled", metadata: .describing(request))
                
                // Workaround for any potential issues causing background jobs to stall.
                //
                // On iOS 13.6 and later, the OS behaviour is changed, so it remembers the task and re-runs it even if
                // the app is deleted and re-installed.
                //
                // Normally this *should* work fine; but this code is a safety net: In case background tasks are stalled
                // (maybe for reasons similar to iOS 13.5) at least it won’t be indefinite: We just reschedule the job
                // after 24 hours to nudge the system.
                switch request.earliestBeginDate {
                case nil:
                    Self.logger.warning("existing background task request does not have any begin date. Re-scheduling the task")
                    self.scheduleNextTask()
                case .some(let date) where date < Date(timeIntervalSinceNow: -86400):
                    Self.logger.warning("existing background task requested begin date is older than a day. Re-scheduling the task")
                    self.scheduleNextTask()
                default:
                    break
                }
            } else {
                self.scheduleNextTask()
            }
        }
    }
    
    func stop() {
        manager.cancelPendingRequest()
    }
}
